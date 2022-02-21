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

    let session_0_complete_1_round_paper_stone = 
        let x : SHIFUMI.shifumiEntrypoints contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session") in
        let () = Test.set_source alice in
        let session_args : SHIFUMI.createsession_param = { total_rounds=1n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.player set)) } in
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
        //let () = Test.log(play_args) in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice plays in (session=0n, round=1) 
        let () = Test.log("alice plays in session 0 round 1") in
        let () = Test.set_source alice in
        let alice_payload_v : SHIFUMI.action = Stone in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let play_args : SHIFUMI.play_param = {sessionId=0n; roundId=1n; action=alice_chest} in
        //let () = Test.log(play_args) in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in


        // alice reveals
        let () = Test.log("alice reveals in session 0 round 1") in
        let () = Test.set_source alice in
        let reveal_args : SHIFUMI.reveal_param = {
            sessionId=0n;
            roundId=1n;
            //player_chest=alice_chest;
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
            //player_chest=bob_chest;
            player_key=bob_chest_key;
            player_secret=bob_secret_1
        } in
        //let () = Test.log(reveal_args) in
        let _ = Test.transfer_to_contract_exn x (RevealPlay(bob_reveal_args)) 0mutez in

        // check storage
        let () = Test.log("check storage") in
        let s2 : SHIFUMI.shifumiStorage = Test.get_storage addr in
        //let () = Test.log(s2) in
        let session_0 : SHIFUMI.session = match Map.find_opt 0n s2.sessions with
        | None -> failwith("could not find session 0")
        | Some sess -> sess 
        in
        let board_round_1 : address option = match Map.find_opt 1n session_0.board with
        | None -> failwith("DRAW")
        | Some addr -> addr
        in
        let () = assert (Option.unopt board_round_1 = bob) in
        let () = assert (session_0.result = Winner(bob)) in
        Test.log("test finished")
    in
    let session_1_partial_1_round_paper_stone = 
        let x : SHIFUMI.shifumiEntrypoints contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session") in
        let () = Test.set_source alice in
        let session_args : SHIFUMI.createsession_param = { total_rounds=3n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.player set)) } in
        //let () = Test.log(commit_args) in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in
        //let store_ : SHIFUMI.shifumiStorage = Test.get_storage addr in
        //let () = Test.log(store_) in

        // bob plays in (session=0n, round=1) 
        let () = Test.log("bob plays in session 0 round 1") in
        let () = Test.set_source bob in
        let bob_payload_v : SHIFUMI.action = Paper in
        let bob_payload : bytes = Bytes.pack bob_payload_v in
        let bob_secret_1 : nat = 10n in 
        let (bob_chest,bob_chest_key) = Test.create_chest bob_payload bob_secret_1 in
        let play_args : SHIFUMI.play_param = {sessionId=1n; roundId=1n; action=bob_chest} in
        //let () = Test.log(play_args) in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice plays in (session=0n, round=1) 
        let () = Test.log("alice plays in session 0 round 1") in
        let () = Test.set_source alice in
        let alice_payload_v : SHIFUMI.action = Stone in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let play_args : SHIFUMI.play_param = {sessionId=1n; roundId=1n; action=alice_chest} in
        //let () = Test.log(play_args) in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in


        // alice reveals
        let () = Test.log("alice reveals in session 0 round 1") in
        let () = Test.set_source alice in
        let reveal_args : SHIFUMI.reveal_param = {
            sessionId=1n;
            roundId=1n;
            //player_chest=alice_chest;
            player_key=alice_chest_key;
            player_secret=alice_secret_1
        } in
        //let () = Test.log(reveal_args) in
        let _ = Test.transfer_to_contract_exn x (RevealPlay(reveal_args)) 0mutez in


        // bob reveals
        let () = Test.log("bob reveals in session 0 round 1") in
        let () = Test.set_source bob in
        let bob_reveal_args : SHIFUMI.reveal_param = {
            sessionId=1n;
            roundId=1n;
            //player_chest=bob_chest;
            player_key=bob_chest_key;
            player_secret=bob_secret_1
        } in
        //let () = Test.log(reveal_args) in
        let _ = Test.transfer_to_contract_exn x (RevealPlay(bob_reveal_args)) 0mutez in

        // check storage
        let () = Test.log("check storage") in
        let s2 : SHIFUMI.shifumiStorage = Test.get_storage addr in
        //let () = Test.log(s2) in
        let session_1 : SHIFUMI.session = match Map.find_opt 1n s2.sessions with
        | None -> failwith("could not find session 0")
        | Some sess -> sess 
        in
        let board_round_1 : address option = match Map.find_opt 1n session_1.board with
        | None -> failwith("DRAW")
        | Some addr -> addr
        in
        let () = assert (Option.unopt board_round_1 = bob) in
        let () = assert (session_1.result = Inplay) in
        Test.log("test finished")
    in
    let session_2_complete_1_round_paper_paper = 
        let x : SHIFUMI.shifumiEntrypoints contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session") in
        let () = Test.set_source alice in
        let session_args : SHIFUMI.createsession_param = { total_rounds=1n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.player set)) } in
        //let () = Test.log(commit_args) in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in
        //let store_ : SHIFUMI.shifumiStorage = Test.get_storage addr in
        //let () = Test.log(store_) in

        // bob plays in (session=0n, round=1) 
        let () = Test.log("bob plays in session 2 round 1") in
        let () = Test.set_source bob in
        let bob_payload_v : SHIFUMI.action = Paper in
        let bob_payload : bytes = Bytes.pack bob_payload_v in
        let bob_secret_1 : nat = 10n in 
        let (bob_chest,bob_chest_key) = Test.create_chest bob_payload bob_secret_1 in
        let play_args : SHIFUMI.play_param = {sessionId=2n; roundId=1n; action=bob_chest} in
        //let () = Test.log(play_args) in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice plays in (session=0n, round=1) 
        let () = Test.log("alice plays in session 2 round 1") in
        let () = Test.set_source alice in
        let alice_payload_v : SHIFUMI.action = Paper in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let play_args : SHIFUMI.play_param = {sessionId=2n; roundId=1n; action=alice_chest} in
        //let () = Test.log(play_args) in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in


        // alice reveals
        let () = Test.log("alice reveals in session 0 round 1") in
        let () = Test.set_source alice in
        let reveal_args : SHIFUMI.reveal_param = {
            sessionId=2n;
            roundId=1n;
            //player_chest=alice_chest;
            player_key=alice_chest_key;
            player_secret=alice_secret_1
        } in
        //let () = Test.log(reveal_args) in
        let _ = Test.transfer_to_contract_exn x (RevealPlay(reveal_args)) 0mutez in


        // bob reveals
        let () = Test.log("bob reveals in session 0 round 1") in
        let () = Test.set_source bob in
        let bob_reveal_args : SHIFUMI.reveal_param = {
            sessionId=2n;
            roundId=1n;
            //player_chest=bob_chest;
            player_key=bob_chest_key;
            player_secret=bob_secret_1
        } in
        //let () = Test.log(reveal_args) in
        let _ = Test.transfer_to_contract_exn x (RevealPlay(bob_reveal_args)) 0mutez in

        // check storage
        let () = Test.log("check storage") in
        let s2 : SHIFUMI.shifumiStorage = Test.get_storage addr in
        let () = Test.log(s2) in
        let session_2 : SHIFUMI.session = match Map.find_opt 2n s2.sessions with
        | None -> failwith("could not find session 0")
        | Some sess -> sess 
        in
        let board_round_1 : address option = match Map.find_opt 1n session_2.board with
        | None -> (None : address option)
        | Some addr -> addr
        in
        let () = assert (board_round_1 = (None : address option)) in
        let () = assert (session_2.result = Draw) in
        Test.log("test finished")
    in

    ()
