
#import "../contracts/main.mligo" "Factory"

let test =
    let () = Test.reset_state 4n ([] : tez list) in
    let alice: address = Test.nth_bootstrap_account 0 in
    let bob: address = Test.nth_bootstrap_account 1 in
    let steven: address = Test.nth_bootstrap_account 2 in
    let frank: address = Test.nth_bootstrap_account 3 in

    let init_storage : Factory.Storage.t = { 
        all_collections=(Big_map.empty : (Factory.Storage.collectionContract, Factory.Storage.collectionOwner) big_map);
        owned_collections=(Big_map.empty : (Factory.Storage.collectionOwner, Factory.Storage.collectionContract set) big_map);
    } in
    let (addr,_,_) = Test.originate Factory.main init_storage 0tez in
    let s_init = Test.get_storage addr in
    let () = Test.log(s_init) in


    let _generates_collection_should_works = 
        let () = Test.log("Test 1 starts") in

        let x : Factory.parameter contract = Test.to_contract addr in

        let () = Test.log("alice generates a collection") in
        let () = Test.set_source alice in
        let gencol_args : Factory.Parameter.generate_collection_param = {name="alice_collection_1"} in
        //let () = Test.log(gencol_args) in
        let _ = Test.transfer_to_contract_exn x (GenerateCollection(gencol_args)) 0mutez in

        let () = Test.log("check alice collection") in
        let s : Factory.storage = Test.get_storage addr in
        let colls : address set = match Big_map.find_opt alice s.owned_collections with
        | None -> (Set.empty : address set)
        | Some x -> x
        in
        let owned_coll_size : nat = Set.size colls in 
        let () = assert (owned_coll_size = 1n) in
        Test.log(s)
    in
    ()