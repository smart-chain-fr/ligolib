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
        let current_session_id : nat = 0n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in


        // bob plays in (session=0n, round=1) 
        let () = Test.log("bob plays in session 0 round 1") in
        let () = Test.set_source bob in
        let bob_payload_v : SHIFUMI.action = Paper in
        let bob_payload : bytes = Bytes.pack bob_payload_v in
        let bob_secret_1 : nat = 10n in 
        let (bob_chest,bob_chest_key) = Test.create_chest bob_payload bob_secret_1 in
        let play_args : SHIFUMI.play_param = {sessionId=current_session_id; roundId=1n; action=bob_chest} in
        //let () = Test.log(play_args) in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice plays in (session=0n, round=1) 
        let () = Test.log("alice plays in session 0 round 1") in
        let () = Test.set_source alice in
        let alice_payload_v : SHIFUMI.action = Stone in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let play_args : SHIFUMI.play_param = {sessionId=current_session_id; roundId=1n; action=alice_chest} in
        //let () = Test.log(play_args) in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice reveals
        let () = Test.log("alice reveals in session 0 round 1") in
        let () = Test.set_source alice in
        let reveal_args : SHIFUMI.reveal_param = {
            sessionId=current_session_id;
            roundId=1n;
            player_key=alice_chest_key;
            player_secret=alice_secret_1
        } in
        //let () = Test.log(reveal_args) in
        let _ = Test.transfer_to_contract_exn x (RevealPlay(reveal_args)) 0mutez in

        // bob reveals
        let () = Test.log("bob reveals in session 0 round 1") in
        let () = Test.set_source bob in
        let bob_reveal_args : SHIFUMI.reveal_param = {
            sessionId=current_session_id;
            roundId=1n;
            player_key=bob_chest_key;
            player_secret=bob_secret_1
        } in
        //let () = Test.log(reveal_args) in
        let _ = Test.transfer_to_contract_exn x (RevealPlay(bob_reveal_args)) 0mutez in

        // check storage
        let () = Test.log("check storage") in
        let s2 : SHIFUMI.shifumiStorage = Test.get_storage addr in
        //let () = Test.log(s2) in
        let session_0 : SHIFUMI.session = match Map.find_opt current_session_id s2.sessions with
        | None -> failwith("could not find session 0")
        | Some sess -> sess 
        in
        let board_round_1 : address option = match Map.find_opt 1n session_0.board with
        | None -> (None : address option)
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
        let current_session_id : nat = 1n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in
        //let store_ : SHIFUMI.shifumiStorage = Test.get_storage addr in
        //let () = Test.log(store_) in

        // bob plays in (session=0n, round=1) 
        let () = Test.log("bob plays in session 1 round 1") in
        let () = Test.set_source bob in
        let bob_payload_v : SHIFUMI.action = Paper in
        let bob_payload : bytes = Bytes.pack bob_payload_v in
        let bob_secret_1 : nat = 10n in 
        let (bob_chest,bob_chest_key) = Test.create_chest bob_payload bob_secret_1 in
        let play_args : SHIFUMI.play_param = {sessionId=current_session_id; roundId=1n; action=bob_chest} in
        //let () = Test.log(play_args) in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice plays in (session=0n, round=1) 
        let () = Test.log("alice plays in session 1 round 1") in
        let () = Test.set_source alice in
        let alice_payload_v : SHIFUMI.action = Stone in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let play_args : SHIFUMI.play_param = {sessionId=current_session_id; roundId=1n; action=alice_chest} in
        //let () = Test.log(play_args) in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in


        // alice reveals
        let () = Test.log("alice reveals in session 1 round 1") in
        let () = Test.set_source alice in
        let reveal_args : SHIFUMI.reveal_param = {
            sessionId=current_session_id;
            roundId=1n;
            //player_chest=alice_chest;
            player_key=alice_chest_key;
            player_secret=alice_secret_1
        } in
        //let () = Test.log(reveal_args) in
        let _ = Test.transfer_to_contract_exn x (RevealPlay(reveal_args)) 0mutez in


        // bob reveals
        let () = Test.log("bob reveals in session 1 round 1") in
        let () = Test.set_source bob in
        let bob_reveal_args : SHIFUMI.reveal_param = {
            sessionId=current_session_id;
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
        let session_1 : SHIFUMI.session = match Map.find_opt current_session_id s2.sessions with
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
    let session_2_complete_1_round_paper_paper_finish_in_draw = 
        let x : SHIFUMI.shifumiEntrypoints contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session") in
        let () = Test.set_source alice in
        let session_args : SHIFUMI.createsession_param = { total_rounds=1n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.player set)) } in
        //let () = Test.log(commit_args) in
        let current_session_id : nat = 2n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in

        // bob plays in (session=0n, round=1) 
        let () = Test.log("bob plays in session 2 round 1") in
        let () = Test.set_source bob in
        let bob_payload_v : SHIFUMI.action = Paper in
        let bob_payload : bytes = Bytes.pack bob_payload_v in
        let bob_secret_1 : nat = 10n in 
        let (bob_chest,bob_chest_key) = Test.create_chest bob_payload bob_secret_1 in
        let play_args : SHIFUMI.play_param = {sessionId=current_session_id; roundId=1n; action=bob_chest} in
        //let () = Test.log(play_args) in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice plays in (session=0n, round=1) 
        let () = Test.log("alice plays in session 2 round 1") in
        let () = Test.set_source alice in
        let alice_payload_v : SHIFUMI.action = Paper in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let play_args : SHIFUMI.play_param = {sessionId=current_session_id; roundId=1n; action=alice_chest} in
        //let () = Test.log(play_args) in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in


        // alice reveals
        let () = Test.log("alice reveals in session 2 round 1") in
        let () = Test.set_source alice in
        let reveal_args : SHIFUMI.reveal_param = {
            sessionId=current_session_id;
            roundId=1n;
            //player_chest=alice_chest;
            player_key=alice_chest_key;
            player_secret=alice_secret_1
        } in
        //let () = Test.log(reveal_args) in
        let _ = Test.transfer_to_contract_exn x (RevealPlay(reveal_args)) 0mutez in


        // bob reveals
        let () = Test.log("bob reveals in session 2 round 1") in
        let () = Test.set_source bob in
        let bob_reveal_args : SHIFUMI.reveal_param = {
            sessionId=current_session_id;
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
        let session_2 : SHIFUMI.session = match Map.find_opt current_session_id s2.sessions with
        | None -> failwith("could not find session 2")
        | Some sess -> sess 
        in
        let () = Test.log(session_2) in
        let board_round_1 : address option = match Map.find_opt 1n session_2.board with
        | None -> (None : address option)
        | Some addr -> addr
        in
        let () = assert (board_round_1 = (None : address option)) in
        let () = assert (session_2.result = Draw) in
        Test.log("test finished")
    in
    let session_3_complete_1_round_paper_paper_finish_in_draw = 
        let x : SHIFUMI.shifumiEntrypoints contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session") in
        let () = Test.set_source alice in
        let session_args : SHIFUMI.createsession_param = { total_rounds=2n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.player set)) } in
        //let () = Test.log(commit_args) in
        let current_session_id : nat = 3n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in

        // bob plays in (session=3n, round=1) 
        let () = Test.log("bob plays in session 3 round 1") in
        let () = Test.set_source bob in
        let bob_payload_v : SHIFUMI.action = Paper in
        let bob_payload : bytes = Bytes.pack bob_payload_v in
        let bob_secret_1 : nat = 10n in 
        let (bob_chest,bob_chest_key) = Test.create_chest bob_payload bob_secret_1 in
        let play_args : SHIFUMI.play_param = {sessionId=current_session_id; roundId=1n; action=bob_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice plays in (session=3n, round=1) 
        let () = Test.log("alice plays in session 3 round 1") in
        let () = Test.set_source alice in
        let alice_payload_v : SHIFUMI.action = Stone in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let play_args : SHIFUMI.play_param = {sessionId=current_session_id; roundId=1n; action=alice_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice reveals in (session=3n, round=1) 
        let () = Test.log("alice reveals in session 3 round 1") in
        let () = Test.set_source alice in
        let reveal_args : SHIFUMI.reveal_param = {
            sessionId=current_session_id;
            roundId=1n;
            player_key=alice_chest_key;
            player_secret=alice_secret_1
        } in
        let _ = Test.transfer_to_contract_exn x (RevealPlay(reveal_args)) 0mutez in

        // bob reveals in (session=3n, round=1) 
        let () = Test.log("bob reveals in session 3 round 1") in
        let () = Test.set_source bob in
        let bob_reveal_args : SHIFUMI.reveal_param = {
            sessionId=current_session_id;
            roundId=1n;
            player_key=bob_chest_key;
            player_secret=bob_secret_1
        } in
        let _ = Test.transfer_to_contract_exn x (RevealPlay(bob_reveal_args)) 0mutez in

        // bob plays in (session=3n, round=2) 
        let () = Test.log("bob plays in session 3 round 2") in
        let () = Test.set_source bob in
        let bob_payload_v : SHIFUMI.action = Stone in
        let bob_payload : bytes = Bytes.pack bob_payload_v in
        let bob_secret_1 : nat = 10n in 
        let (bob_chest,bob_chest_key) = Test.create_chest bob_payload bob_secret_1 in
        let play_args : SHIFUMI.play_param = {sessionId=current_session_id; roundId=2n; action=bob_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice plays in (session=3n, round=2) 
        let () = Test.log("alice plays in session 3 round 2") in
        let () = Test.set_source alice in
        let alice_payload_v : SHIFUMI.action = Paper in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let play_args : SHIFUMI.play_param = {sessionId=current_session_id; roundId=2n; action=alice_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice reveals in (session=3n, round=2) 
        let () = Test.log("alice reveals in session 3 round 2") in
        let () = Test.set_source alice in
        let reveal_args : SHIFUMI.reveal_param = {
            sessionId=current_session_id;
            roundId=2n;
            player_key=alice_chest_key;
            player_secret=alice_secret_1
        } in
        let _ = Test.transfer_to_contract_exn x (RevealPlay(reveal_args)) 0mutez in

        // bob reveals in (session=3n, round=2) 
        let () = Test.log("bob reveals in session 3 round 2") in
        let () = Test.set_source bob in
        let bob_reveal_args : SHIFUMI.reveal_param = {
            sessionId=current_session_id;
            roundId=2n;
            player_key=bob_chest_key;
            player_secret=bob_secret_1
        } in
        let _ = Test.transfer_to_contract_exn x (RevealPlay(bob_reveal_args)) 0mutez in

        // check storage
        let () = Test.log("check storage") in
        let s2 : SHIFUMI.shifumiStorage = Test.get_storage addr in
        //let () = Test.log(s2) in
        let session_3 : SHIFUMI.session = match Map.find_opt current_session_id s2.sessions with
        | None -> failwith("could not find session 2")
        | Some sess -> sess 
        in
        let () = Test.log(session_3) in
        let board_round_1 : address option = match Map.find_opt 1n session_3.board with
        | None -> (None : address option)
        | Some addr -> addr
        in
        let board_round_2 : address option = match Map.find_opt 2n session_3.board with
        | None -> (None : address option)
        | Some addr -> addr
        in
        let () = assert (Option.unopt board_round_1 = bob) in
        let () = assert (Option.unopt board_round_2 = alice) in
        let () = assert (session_3.result = Draw) in
        Test.log("test finished")
    in
    let session_4_partial_stopped = 
        let x : SHIFUMI.shifumiEntrypoints contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session") in
        let () = Test.set_source alice in
        let session_args : SHIFUMI.createsession_param = { total_rounds=3n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.player set)) } in
        //let () = Test.log(commit_args) in
        let current_session_id : nat = 4n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in
        //let store_ : SHIFUMI.shifumiStorage = Test.get_storage addr in
        //let () = Test.log(store_) in

        // bob plays in (session=0n, round=1) 
        let () = Test.log("bob plays in session 1 round 1") in
        let () = Test.set_source bob in
        let bob_payload_v : SHIFUMI.action = Paper in
        let bob_payload : bytes = Bytes.pack bob_payload_v in
        let bob_secret_1 : nat = 10n in 
        let (bob_chest,bob_chest_key) = Test.create_chest bob_payload bob_secret_1 in
        let play_args : SHIFUMI.play_param = {sessionId=current_session_id; roundId=1n; action=bob_chest} in
        //let () = Test.log(play_args) in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        //TODO
        //let () = Test.set_now (Tezos.now + 600) in

        // bob stops session (session=4n) 
        let () = Test.log("bob stops session 4") in
        let () = Test.set_source bob in
        let alice_payload_v : SHIFUMI.action = Stone in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let stop_args : SHIFUMI.stopsession_param = {sessionId=current_session_id} in
        //let () = Test.log(play_args) in
        let _ = Test.transfer_to_contract_exn x (StopSession(stop_args)) 0mutez in

        // check storage
        let () = Test.log("check storage") in
        let s2 : SHIFUMI.shifumiStorage = Test.get_storage addr in
        //let () = Test.log(s2) in
        let session_4 : SHIFUMI.session = match Map.find_opt current_session_id s2.sessions with
        | None -> failwith("could not find session 0")
        | Some sess -> sess 
        in
        let board_round_1 : address option = match Map.find_opt 1n session_4.board with
        | None -> failwith("DRAW")
        | Some addr -> addr
        in
        let () = assert (session_4.result <> Winner(bob)) in
        Test.log("test finished")
    in
    ()
