#import "main.mligo" "SHIFUMI"

let test =
    let alice: address = Test.nth_bootstrap_account 0 in
    let bob: address = Test.nth_bootstrap_account 1 in
    let init_storage : SHIFUMI.shifumiStorage = { 
        next_session=0n;
        sessions=(Map.empty : (nat, SHIFUMI.session) map)
    } in
    let (addr,_,_) = Test.originate SHIFUMI.shifumiMain init_storage 0tez in
    let s_init = Test.get_storage addr in
    let () = Test.log(s_init) in

    let _test_should_works = (* chest key/payload and time matches -> OK *)
        //let payload2 : bytes = 0x02 in
        //let time_secret2 : nat = 99n in 
        //let (my_chest2,chest_key2) = Test.create_chest payload2 time_secret2 in

        //let () = Test.log("chests created") in

        let x : SHIFUMI.shifumiEntrypoints contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session") in
        let () = Test.set_source alice in
        let session_args : SHIFUMI.createsession_param = { total_rounds=10n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.player set)) } in
        //let () = Test.log(commit_args) in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in

        //let store : storage = Test.get_storage addr in


        // bob plays in (session=0n, round=1) 
        let () = Test.log("bob plays in session 0 round 1") in
        let () = Test.set_source bob in
        let bob_payload_v : SHIFUMI.action = Paper in
        let bob_payload : bytes = Bytes.pack bob_payload_v in
        let bob_secret_1 : nat = 10n in 
        let (bob_chest,bob_chest_key) = Test.create_chest bob_payload bob_secret_1 in
        let play_args : SHIFUMI.play_param = {sessionId=0n; roundId=1n; action=bob_chest} in
        let () = Test.log(play_args) in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice plays in (session=0n, round=1) 
        let () = Test.log("alice plays in session 0 round 1") in
        let () = Test.set_source alice in
        let alice_payload_v : SHIFUMI.action = Stone in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let play_args : SHIFUMI.play_param = {sessionId=0n; roundId=1n; action=alice_chest} in
        let () = Test.log(play_args) in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in


        // alice reveals
        let () = Test.log("alice reveals in session 0 round 1") in
        let () = Test.set_source alice in
        let reveal_args : SHIFUMI.reveal_param = {
            sessionId=0n;
            roundId=1n;
            player_chest=alice_chest;
            player_key=alice_chest_key;
            player_secret=alice_secret_1
        } in
        //let () = Test.log(reveal_args) in
        let _ = Test.transfer_to_contract_exn x (RevealPlay(reveal_args)) 0mutez in


        // bob reveals
        let () = Test.log("bob reveals in session 0 round 1") in
        let () = Test.set_source bob in
        let bob_reveal_args : SHIFUMI.reveal_param = {
            sessionId=0n;
            roundId=1n;
            player_chest=bob_chest;
            player_key=bob_chest_key;
            player_secret=bob_secret_1
        } in
        //let () = Test.log(reveal_args) in
        let _ = Test.transfer_to_contract_exn x (RevealPlay(bob_reveal_args)) 0mutez in

        // check storage
        let () = Test.log("check storage") in
        let s2 : SHIFUMI.shifumiStorage = Test.get_storage addr in
        //let () = assert (s2.result <> (None : bytes option)) in
        let () = Test.log(s2) in
        Test.log("test finished")
    in
    ()
