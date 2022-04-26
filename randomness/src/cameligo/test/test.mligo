#import "../contracts/main.mligo" "Random"


let test =
    let alice: address = Test.nth_bootstrap_account 0 in
    let bob: address = Test.nth_bootstrap_account 1 in

    let init_seed : nat = 3268854739249n in
    let init_storage : Random.Storage.Types.t = { 
        participants= Set.add alice (Set.add bob (Set.empty : address set));
        locked_tez=(Map.empty : (address, tez) map);
        secrets=(Map.empty: (address, chest) map); 
        decoded_payloads=(Map.empty: (address, bytes) map); 
        result_nat=(None : nat option);
        last_seed=init_seed;
        max=1000n;
        min=100n
    } in
    // originate Random smart contract
    let (addr,_,_) = Test.originate Random.main init_storage 0tez in
    let s_init = Test.get_storage addr in
    //let () = Test.log(s_init) in

    let _test_should_works = (* chest key/payload and time matches -> OK *)
    
        let payload : bytes = 0x0a in
        let time_secret : nat = 10n in 
        let (my_chest,chest_key) = Test.create_chest payload time_secret in

        let payload2 : bytes = 0x0b in
        let time_secret2 : nat = 99n in 
        let (my_chest2,chest_key2) = Test.create_chest payload2 time_secret2 in

        let x : Random.parameter contract = Test.to_contract addr in

        // alice commits
        let () = Test.set_source alice in
        let commit_args : Random.Parameter.Types.commit_param = {secret_action=my_chest} in
        let _ = Test.transfer_to_contract_exn x (Commit(commit_args)) 10mutez in

        let s : Random.storage = Test.get_storage addr in
        let response : bool = match Map.find_opt alice s.secrets with
        | None -> false
        | Some x -> true
        in
        let () = assert (response) in

        // bob commits
        let () = Test.set_source bob in
        let commit_args2 : Random.Parameter.Types.commit_param = {secret_action=my_chest2} in
        let _ = Test.transfer_to_contract_exn x (Commit(commit_args2)) 10mutez in

        let s3 : Random.storage = Test.get_storage addr in
        let response2 : bool = match Map.find_opt bob s3.secrets with
        | None -> false
        | Some x -> true
        in
        let () = assert (response2) in

        // alice reveals
        let () = Test.set_source alice in
        let reveal_args : Random.Parameter.Types.reveal_param = (chest_key, time_secret) in
        let _ = Test.transfer_to_contract_exn x (Reveal(reveal_args)) 0mutez in

        // bob reveals
        let () = Test.set_source bob in
        let reveal_args2 : Random.Parameter.Types.reveal_param = (chest_key2, time_secret2) in
        let _ = Test.transfer_to_contract_exn x (Reveal(reveal_args2)) 0mutez in
        
        let s2 : Random.storage = Test.get_storage addr in
        let () = assert (s2.result_nat <> (None : nat option)) in
        "OK"
    in
    ()

let test2 =
    let alice: address = Test.nth_bootstrap_account 0 in
    let bob: address = Test.nth_bootstrap_account 1 in
    let init_seed : nat = 3268854739249n in
    let init_storage : Random.Storage.Types.t = { 
        participants= Set.add alice (Set.add bob (Set.empty : address set));
        locked_tez=(Map.empty : (address, tez) map);
        secrets=(Map.empty: (address, chest) map); 
        decoded_payloads=(Map.empty: (address, bytes) map); 
        result_nat=(None : nat option);
        last_seed=init_seed;
        max=1000n;
        min=1n
    } in
    // originate Random smart contract
    let (addr,_,_) = Test.originate Random.main init_storage 0tez in
    let s_init = Test.get_storage addr in

    let _test_rollD1000 = 
    
        let payload : bytes = 0x0a1234 in
        let time_secret : nat = 10n in 
        let (my_chest,chest_key) = Test.create_chest payload time_secret in

        let payload2 : bytes = 0x0b455469 in
        let time_secret2 : nat = 84n in 
        let (my_chest2,chest_key2) = Test.create_chest payload2 time_secret2 in

        let x : Random.parameter contract = Test.to_contract addr in

        // alice commits
        let () = Test.set_source alice in
        let commit_args : Random.Parameter.Types.commit_param = {secret_action=my_chest} in
        let _ = Test.transfer_to_contract_exn x (Commit(commit_args)) 10mutez in

        // bob commits
        let () = Test.set_source bob in
        let commit_args2 : Random.Parameter.Types.commit_param = {secret_action=my_chest2} in
        let _ = Test.transfer_to_contract_exn x (Commit(commit_args2)) 10mutez in

        // alice reveals
        let () = Test.set_source alice in
        let reveal_args : Random.Parameter.Types.reveal_param = (chest_key, time_secret) in
        let _ = Test.transfer_to_contract_exn x (Reveal(reveal_args)) 0mutez in

        // bob reveals
        let () = Test.set_source bob in
        let reveal_args2 : Random.Parameter.Types.reveal_param = (chest_key2, time_secret2) in
        let _ = Test.transfer_to_contract_exn x (Reveal(reveal_args2)) 0mutez in
        
        let s2 : Random.storage = Test.get_storage addr in
        let () = Test.log(s2.result_nat) in
        let () = assert (s2.result_nat <> (None : nat option)) in
        "OK"
    in
    let _test_rollD20 = 
    
        let payload : bytes = 0x0a1234 in
        let time_secret : nat = 10n in 
        let (my_chest,chest_key) = Test.create_chest payload time_secret in

        let payload2 : bytes = 0x0b455469 in
        let time_secret2 : nat = 84n in 
        let (my_chest2,chest_key2) = Test.create_chest payload2 time_secret2 in


        let x : Random.parameter contract = Test.to_contract addr in

        // alice reset
        let () = Test.set_source alice in
        let reset_args : Random.Parameter.Types.reset_param = {min=1n; max=20n} in
        let _ = Test.transfer_to_contract_exn x (Reset(reset_args)) 0mutez in


        // alice commits
        let () = Test.set_source alice in
        let commit_args : Random.Parameter.Types.commit_param = {secret_action=my_chest} in
        let _ = Test.transfer_to_contract_exn x (Commit(commit_args)) 10mutez in

        // bob commits
        let () = Test.set_source bob in
        let commit_args2 : Random.Parameter.Types.commit_param = {secret_action=my_chest2} in
        let _ = Test.transfer_to_contract_exn x (Commit(commit_args2)) 10mutez in

        // alice reveals
        let () = Test.set_source alice in
        let reveal_args : Random.Parameter.Types.reveal_param = (chest_key, time_secret) in
        let _ = Test.transfer_to_contract_exn x (Reveal(reveal_args)) 0mutez in

        // bob reveals
        let () = Test.set_source bob in
        let reveal_args2 : Random.Parameter.Types.reveal_param = (chest_key2, time_secret2) in
        let _ = Test.transfer_to_contract_exn x (Reveal(reveal_args2)) 0mutez in

        let s2 : Random.storage = Test.get_storage addr in
        let () = Test.log(s2.result_nat) in
        let () = assert (s2.result_nat <> (None : nat option)) in
        let result : nat = Option.unopt s2.result_nat in 
        let () = assert (result <= s2.max) in
        let () = assert (result >= s2.min) in
        "OK"
    in
    let _test_rollD20_again = 
    
        let payload : bytes = 0x0a1234 in
        let time_secret : nat = 10n in 
        let (my_chest,chest_key) = Test.create_chest payload time_secret in

        let payload2 : bytes = 0x0b455469 in
        let time_secret2 : nat = 84n in 
        let (my_chest2,chest_key2) = Test.create_chest payload2 time_secret2 in

        let x : Random.parameter contract = Test.to_contract addr in

        // alice reset
        let () = Test.set_source alice in
        let reset_args : Random.Parameter.Types.reset_param = {min=1n; max=20n} in
        let _ = Test.transfer_to_contract_exn x (Reset(reset_args)) 0mutez in


        // alice commits
        let () = Test.set_source alice in
        let commit_args : Random.Parameter.Types.commit_param = {secret_action=my_chest} in
        let _ = Test.transfer_to_contract_exn x (Commit(commit_args)) 10mutez in

        // bob commits
        let () = Test.set_source bob in
        let commit_args2 : Random.Parameter.Types.commit_param = {secret_action=my_chest2} in
        let _ = Test.transfer_to_contract_exn x (Commit(commit_args2)) 10mutez in

        // alice reveals
        let () = Test.set_source alice in
        let reveal_args : Random.Parameter.Types.reveal_param = (chest_key, time_secret) in
        let _ = Test.transfer_to_contract_exn x (Reveal(reveal_args)) 0mutez in

        // bob reveals
        let () = Test.set_source bob in
        let reveal_args2 : Random.Parameter.Types.reveal_param = (chest_key2, time_secret2) in
        let _ = Test.transfer_to_contract_exn x (Reveal(reveal_args2)) 0mutez in
        
        let s2 : Random.storage = Test.get_storage addr in
        let () = Test.log(s2.result_nat) in
        let () = assert (s2.result_nat <> (None : nat option)) in
        let result : nat = Option.unopt s2.result_nat in 
        let () = assert (result <= s2.max) in
        let () = assert (result >= s2.min) in
        "OK"
    in
    let _test_rollD20_again_again = 
    
        let payload : bytes = 0x0a1234 in
        let time_secret : nat = 10n in 
        let (my_chest,chest_key) = Test.create_chest payload time_secret in

        let payload2 : bytes = 0x0b455469 in
        let time_secret2 : nat = 84n in 
        let (my_chest2,chest_key2) = Test.create_chest payload2 time_secret2 in

        let x : Random.parameter contract = Test.to_contract addr in

        // alice reset
        let () = Test.set_source alice in
        let reset_args : Random.Parameter.Types.reset_param = {min=1n; max=20n} in
        let _ = Test.transfer_to_contract_exn x (Reset(reset_args)) 0mutez in

        // alice commits
        let () = Test.set_source alice in
        let commit_args : Random.Parameter.Types.commit_param = {secret_action=my_chest} in
        let _ = Test.transfer_to_contract_exn x (Commit(commit_args)) 10mutez in

        // bob commits
        let () = Test.set_source bob in
        let commit_args2 : Random.Parameter.Types.commit_param = {secret_action=my_chest2} in
        let _ = Test.transfer_to_contract_exn x (Commit(commit_args2)) 10mutez in

        // alice reveals
        let () = Test.set_source alice in
        let reveal_args : Random.Parameter.Types.reveal_param = (chest_key, time_secret) in
        let _ = Test.transfer_to_contract_exn x (Reveal(reveal_args)) 0mutez in

        // check locked tez before bob reveals
        let bob_balance_of_before_reveal = Test.get_balance bob in
        let storage_before_bob_reveals : Random.storage = Test.get_storage addr in
        let bob_locked_tez_opt : tez option = Map.find_opt bob storage_before_bob_reveals.locked_tez in
        let bob_locked_tez_before_reveal : tez =  match bob_locked_tez_opt with
        | None -> 0tez
        | Some tez_val -> tez_val
        in
        let () = assert(bob_locked_tez_before_reveal = 10mutez) in

        // bob reveals
        let () = Test.set_source bob in
        let reveal_args2 : Random.Parameter.Types.reveal_param = (chest_key2, time_secret2) in
        let _ = Test.transfer_to_contract_exn x (Reveal(reveal_args2)) 0mutez in
        
        // check locked tez after bob reveals
        let storage_after_bob_reveals : Random.storage = Test.get_storage addr in
        let bob_locked_tez_opt : tez option = Map.find_opt bob storage_after_bob_reveals.locked_tez in
        let bob_locked_tez_after_reveal : tez =  match bob_locked_tez_opt with
        | None -> 0tez
        | Some tez_val -> tez_val
        in
        let () = assert(bob_locked_tez_after_reveal = 0mutez) in
        
        let s2 : Random.storage = Test.get_storage addr in
        let () = Test.log(s2.result_nat) in
        let () = assert (s2.result_nat <> (None : nat option)) in
        let result : nat = Option.unopt s2.result_nat in 
        let () = assert (result <= s2.max) in
        let () = assert (result >= s2.min) in
        "OK"
    in
    ()
