#import "../../src/cameligo/proxy.mligo" "Proxy"
#import "../../src/cameligo/errors.mligo" "Errors"
#import "../helpers/assert.mligo" "Assert"

type return = operation list * Proxy.storage
type main_fn = (Proxy.parameter * Proxy.storage) -> return

// Helpers
let proxy_storage (owner:address) (version:string) (versions:(string, address) map) : Proxy.storage = 
   { owner = owner; version = version; versions = versions } 

let base_proxy_storage (owner : address) : Proxy.storage = 
    proxy_storage owner "" (Map.empty : (string, address) map)

let new_proxy (init_storage, main : Proxy.storage * main_fn) = 
    let (addr, _, _) = Test.originate main init_storage 0tez in
    let contr = Test.to_contract addr in
    (addr, contr)

let new_featurev1_address (init_storage : int) =
    let f = "./src/common/featurev1.mligo" in
    let v_mich = Test.run (fun (x:int) -> x) init_storage in
    let (addr, _, _) = Test.originate_from_file f "main" v_mich 0tez in
    addr

let new_featurev2_address (init_storage : (address, int) big_map) =
    let f = "./src/common/featurev2.mligo" in
    let v_mich = Test.run (fun (x:(address, int) big_map) -> x) init_storage in
    let (addr, _, _) = Test.originate_from_file f "main" v_mich 0tez in
    addr

(* Owner *)

(* Test protected entry points *)
let _test_not_owner (main: main_fn) =
    let featurev1_addr = new_featurev1_address(0) in
    let owner = Test.nth_bootstrap_account 0 in
    let (_, c) = new_proxy(base_proxy_storage(owner), main) in

    let sender_ = Test.nth_bootstrap_account 1 in
    let () = Test.set_source sender_ in

    // TODO: iterate over list of parameters?
    let transfer_ownership_result = Test.transfer_to_contract c (TransferOwnership(sender_)) 0mutez in
    let new_version = { label = "someversion"; dest  = featurev1_addr } in
    let add_version_result = Test.transfer_to_contract c (AddVersion(new_version)) 0mutez in
    let set_version_result = Test.transfer_to_contract c (SetVersion("someversion")) 0mutez in

    let () = Assert.string_failure transfer_ownership_result Errors.sender_not_allowed in
    let () = Assert.string_failure add_version_result Errors.sender_not_allowed in
    let () = Assert.string_failure set_version_result Errors.sender_not_allowed in 
    ()

let test_not_owner = _test_not_owner Proxy.main

let _test_not_zero_amount (main: main_fn) = 
    let owner = Test.nth_bootstrap_account 0 in
    let (_, c) = new_proxy(base_proxy_storage(owner), main) in

    let other = Test.nth_bootstrap_account 1 in
    let () = Test.set_source owner in
    let transfer_ownership_result = Test.transfer_to_contract c (TransferOwnership(other)) 3mutez in
    let () = Assert.string_failure transfer_ownership_result Errors.not_zero_amount in
    ()

let test_not_zero_amount = _test_not_zero_amount Proxy.main

(* Test ownership can be transfered *)
let _test_transfer_ownership_success (main: main_fn) =
    let owner = Test.nth_bootstrap_account 0 in
    let storage = base_proxy_storage(owner) in
    let (taddr, c) = new_proxy(storage, main) in

    let new_owner = Test.nth_bootstrap_account 1 in
    let () = Test.set_source owner in
    let _ = Test.transfer_to_contract_exn c (TransferOwnership(new_owner)) 0mutez in

    assert (Test.get_storage taddr = { storage with owner = new_owner})
    

let test_transfer_ownership_success = _test_transfer_ownership_success Proxy.main

(* Proxy Logic *)

(* Test can add new version *)
let _test_add_version_success (main: main_fn) =
    let featurev1_addr = new_featurev1_address(0) in
    let owner = Test.nth_bootstrap_account 0 in
    let storage = base_proxy_storage(owner) in
    let (taddr, c) = new_proxy(storage, main) in

    let () = Test.set_source owner in
    let _ = Test.transfer_to_contract_exn c (AddVersion({
        label = "featurev1";
        dest  = featurev1_addr
    })) 0mutez in

    assert (Test.get_storage taddr = { storage with
        versions = Map.literal[ ("featurev1", featurev1_addr) ]
    })

let test_add_version_success = _test_add_version_success Proxy.main

(* Test can set version *)
let _test_set_version_success (main: main_fn) = 
    let featurev1_addr = new_featurev1_address(0) in
    let owner = Test.nth_bootstrap_account 0 in
    let base_storage = base_proxy_storage(owner) in
    let storage = { base_storage with 
        versions = Map.literal[ ("featurev1", featurev1_addr) ]
    } in
    let (taddr, c) = new_proxy(storage, main) in

    let () = Test.set_source owner in
    let _ = Test.transfer_to_contract_exn c (SetVersion("featurev1")) 0mutez in

    assert (Test.get_storage taddr = { storage with
        version = "featurev1";
        versions = Map.literal[ ("featurev1", featurev1_addr) ]
    })

let test_set_version_success = _test_set_version_success Proxy.main

(* Test add and set version *)
let _test_add_version_then_set_version_success (main: main_fn) = 
    let sender_ = Test.nth_bootstrap_account 0 in
    let featurev1_addr = new_featurev1_address(0) in
    let featurev2_addr = new_featurev2_address(Big_map.literal [sender_, 21]) in
    let owner = Test.nth_bootstrap_account 0 in
    let base_storage = base_proxy_storage(owner) in
    let storage = { base_storage with
        version  = "featurev1";
        versions = Map.literal[ ("featurev1", featurev1_addr) ]
    } in
    let (taddr, c) = new_proxy(storage, main) in

    let () = Test.set_source owner in
    let _ = Test.transfer_to_contract_exn c (AddVersion({
        label = "featurev2";
        dest  = featurev2_addr
    })) 0mutez in
    let _ = Test.transfer_to_contract_exn c (SetVersion("featurev2")) 0mutez in

    assert (Test.get_storage taddr = { storage with
        version  = "featurev2";
        versions = Map.literal[ 
            ("featurev1", featurev1_addr); 
            ("featurev2", featurev2_addr) 
        ]
    }) 

let test_add_version_then_set_version_success = _test_add_version_then_set_version_success Proxy.main

(* Proxy routing *)

(* Test Increment FeatureV1 *)
let _test_increment_success_featurev1 (main: main_fn) = 
    let sender_ = Test.nth_bootstrap_account 0 in
    let featurev1_addr = new_featurev1_address(0) in
    let owner = Test.nth_bootstrap_account 0 in
    let base_storage = base_proxy_storage(owner) in
    let storage = { base_storage with
        version  = "featurev1";
        versions = Map.literal[ ("featurev1", featurev1_addr) ]
    } in
    let (taddr, c) = new_proxy(storage, main) in
    let () = Test.set_source owner in
    let _ = Test.transfer_to_contract_exn c (Increment(1)) 0mutez in
    let actual_storage = Test.get_storage_of_address featurev1_addr in
    assert (actual_storage = Test.run (fun (x:int) -> x) 1)

let test_increment_success_featurev1 = _test_increment_success_featurev1 Proxy.main

(* Test Decrement FeatureV1 *)
let _test_decrement_success_featurev1 (main: main_fn) = 
    let sender_ = Test.nth_bootstrap_account 0 in
    let featurev1_addr = new_featurev1_address(2) in
    let owner = Test.nth_bootstrap_account 0 in
    let base_storage = base_proxy_storage(owner) in
    let storage = { base_storage with
        version  = "featurev1";
        versions = Map.literal[ ("featurev1", featurev1_addr) ]
    } in
    let (taddr, c) = new_proxy(storage, main) in
    let () = Test.set_source owner in
    let _ = Test.transfer_to_contract_exn c (Decrement(1)) 0mutez in
    let actual_storage = Test.get_storage_of_address featurev1_addr in
    assert (actual_storage = Test.run (fun (x:int) -> x) 1)

let test_decrement_success_featurev1 = _test_decrement_success_featurev1 Proxy.main

(* Test Reset FeatureV1 *)
let _test_reset_success_featurev1 (main: main_fn) = 
    let sender_ = Test.nth_bootstrap_account 0 in
    let featurev1_addr = new_featurev1_address(2) in
    let owner = Test.nth_bootstrap_account 0 in
    let base_storage = base_proxy_storage(owner) in
    let storage = { base_storage with
        version  = "featurev1";
        versions = Map.literal[ ("featurev1", featurev1_addr) ]
    } in
    let (taddr, c) = new_proxy(storage, main) in
    let () = Test.set_source owner in
    let _ = Test.transfer_to_contract_exn c (Reset) 0mutez in
    let actual_storage = Test.get_storage_of_address featurev1_addr in
    assert (actual_storage = Test.run (fun (x:int) -> x) 0)

let test_reset_success_featurev1 = _test_reset_success_featurev1 Proxy.main
