#import "../contracts/main.mligo" "Random"


let test =
    let alice: address = Test.nth_bootstrap_account 0 in
    let bob: address = Test.nth_bootstrap_account 1 in
    let init_storage : Random.Storage.Types.t = { 
        participants= Set.add alice (Set.add bob (Set.empty : address set));
        secrets=(Map.empty: (address, chest) map); 
        decoded_payloads=(Map.empty: (address, bytes) map); 
        result=(None : bytes option) 
    } in
    let (addr,_,_) = Test.originate Random.main init_storage 0tez in
    let s_init = Test.get_storage addr in
    let () = Test.log(s_init) in

    let _test_should_works = (* chest key/payload and time matches -> OK *)
    
        let payload : bytes = 0x0a in
        let time_secret : nat = 10n in 
        let (my_chest,chest_key) = Test.create_chest payload time_secret in

        let payload2 : bytes = 0x0b in
        let time_secret2 : nat = 99n in 
        let (my_chest2,chest_key2) = Test.create_chest payload2 time_secret2 in

        let () = Test.log("chests created") in

        let x : Random.parameter contract = Test.to_contract addr in

        // alice commits
        let () = Test.log("alice commits") in
        let () = Test.set_source alice in
        let commit_args : Random.Parameter.Types.commit_param = {secret_action=my_chest} in
        //let () = Test.log(commit_args) in
        let _ = Test.transfer_to_contract_exn x (Commit(commit_args)) 0mutez in

        let () = Test.log("check alice chest") in
        let s : Random.storage = Test.get_storage addr in
        let response : bool = match Map.find_opt alice s.secrets with
        | None -> false
        | Some x -> true
        in
        let () = assert (response) in


        // bob commits
        let () = Test.log("bob commits") in
        let () = Test.set_source bob in
        let commit_args2 : Random.Parameter.Types.commit_param = {secret_action=my_chest2} in
        //let () = Test.log(commit_args) in
        let _ = Test.transfer_to_contract_exn x (Commit(commit_args2)) 0mutez in

        let () = Test.log("check bob chest") in
        let s3 : Random.storage = Test.get_storage addr in
        let response2 : bool = match Map.find_opt bob s3.secrets with
        | None -> false
        | Some x -> true
        in
        let () = assert (response2) in

        // alice reveals
        let () = Test.log("alice reveals") in
        let () = Test.set_source alice in
        let reveal_args : Random.Parameter.Types.reveal_param = (chest_key, time_secret) in
        //let () = Test.log(reveal_args) in
        let _ = Test.transfer_to_contract_exn x (Reveal(reveal_args)) 0mutez in

        // bob reveals
        let () = Test.log("bob reveals") in
        let () = Test.set_source bob in
        let reveal_args2 : Random.Parameter.Types.reveal_param = (chest_key2, time_secret2) in
        let _ = Test.transfer_to_contract_exn x (Reveal(reveal_args2)) 0mutez in
        
        let () = Test.log("check storage") in
        let s2 : Random.storage = Test.get_storage addr in
        let () = Test.log(s2) in
        let () = assert (s2.result <> (None : bytes option)) in
        Test.log("test finished")
    in
    ()
