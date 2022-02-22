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


    let get_session_from_storage(contract_address, sessionId : (SHIFUMI.shifumiEntrypoints, SHIFUMI.shifumiStorage) typed_address * nat) : SHIFUMI.session =
        let storage_with_session : SHIFUMI.shifumiStorage = Test.get_storage contract_address in
        let session_x : SHIFUMI.session = match Map.find_opt sessionId storage_with_session.sessions with
        | None -> failwith("could not find session 0")
        | Some sess -> sess 
        in
        session_x
    in

    let get_round_from_session(sess, roundId : SHIFUMI.session * nat) : SHIFUMI.player_actions =
        let session_x_round_y : SHIFUMI.player_actions = match Map.find_opt roundId sess.rounds with
        | None -> ([]: SHIFUMI.player_actions)
        | Some pactions -> pactions
        in
        session_x_round_y
    in

    let get_decoded_round_from_session(sess, roundId : SHIFUMI.session * nat) : SHIFUMI.decoded_player_actions =
        let session_x_round_y : SHIFUMI.decoded_player_actions = match Map.find_opt roundId sess.decoded_rounds with
        | None -> ([]: SHIFUMI.decoded_player_actions)
        | Some pactions -> pactions
        in
        session_x_round_y
    in

    let session_0_complete_1_round_paper_stone = 
        let x : SHIFUMI.shifumiEntrypoints contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session") in
        let () = Test.set_source alice in
        let session_args : SHIFUMI.createsession_param = { total_rounds=1n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.player set)) } in
        let current_session_id : nat = 0n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in
        // verify session creation
        let session_0 : SHIFUMI.session = get_session_from_storage(addr, current_session_id) in
        let () = assert (session_0.current_round = 1n) in
        let () = assert (session_0.total_rounds = 1n) in
        let () = assert (session_0.result = Inplay) in
        let session_0_round_1 : SHIFUMI.player_actions = get_round_from_session(session_0, 1n) in
        let count (acc, i: nat * SHIFUMI.player_action) : nat = acc + 1n in
        let nb_of_elements : nat = List.fold_left count 0n session_0_round_1 in
        let () = assert (nb_of_elements = 0n) in
        let session_0_decoded_round_1 : SHIFUMI.decoded_player_actions = get_decoded_round_from_session(session_0, 1n) in
        let count_ (acc, i: nat * SHIFUMI.decoded_player_action) : nat = acc + 1n in
        let nb_of_decoded_elements : nat = List.fold count_ session_0_decoded_round_1 0n in
        let () = assert (nb_of_decoded_elements = 0n) in

        // bob plays in (session=0n, round=1) 
        let () = Test.log("bob plays in session 0 round 1") in
        let () = Test.set_source bob in
        let bob_payload_v : SHIFUMI.action = Paper in
        let bob_payload : bytes = Bytes.pack bob_payload_v in
        let bob_secret_1 : nat = 10n in 
        let (bob_chest,bob_chest_key) = Test.create_chest bob_payload bob_secret_1 in
        let play_args : SHIFUMI.play_param = {sessionId=current_session_id; roundId=1n; action=bob_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in
        // verify round register bob chest
        let session_0 : SHIFUMI.session = get_session_from_storage(addr, current_session_id) in
        let () = assert (session_0.current_round = 1n) in
        let () = assert (session_0.total_rounds = 1n) in
        let () = assert (session_0.result = Inplay) in
        let session_0_round_1 : SHIFUMI.player_actions = get_round_from_session(session_0, 1n) in
        let count (acc, i: nat * SHIFUMI.player_action) : nat = acc + 1n in
        let nb_of_elements : nat = List.fold_left count 0n session_0_round_1 in
        let () = assert (nb_of_elements = 1n) in
        let bob_action : SHIFUMI.player_action = Option.unopt (List.head_opt session_0_round_1) in
        let () = assert (bob_action.player = bob) in
        // cannot compare chest
        //let () = assert (bob_action.action = bob_chest) in
        let session_0_decoded_round_1 : SHIFUMI.decoded_player_actions = get_decoded_round_from_session(session_0, 1n) in
        let count_ (acc, i: nat * SHIFUMI.decoded_player_action) : nat = acc + 1n in
        let nb_of_decoded_elements : nat = List.fold_left count_ 0n session_0_decoded_round_1 in
        let () = assert (nb_of_decoded_elements = 0n) in

        // alice plays in (session=0n, round=1) 
        let () = Test.log("alice plays in session 0 round 1") in
        let () = Test.set_source alice in
        let alice_payload_v : SHIFUMI.action = Stone in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let play_args : SHIFUMI.play_param = {sessionId=current_session_id; roundId=1n; action=alice_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in
        // verify round 1 register alice chest
        let session_0 : SHIFUMI.session = get_session_from_storage(addr, current_session_id) in
        let () = assert (session_0.current_round = 1n) in
        let () = assert (session_0.total_rounds = 1n) in
        let () = assert (session_0.result = Inplay) in
        let session_0_round_1 : SHIFUMI.player_actions = get_round_from_session(session_0, 1n) in
        let count (acc, i: nat * SHIFUMI.player_action) : nat = acc + 1n in
        let nb_of_elements : nat = List.fold_left count 0n session_0_round_1 in
        let () = assert (nb_of_elements = 2n) in

        // alice reveals
        let () = Test.log("alice reveals in session 0 round 1") in
        let () = Test.set_source alice in
        let reveal_args : SHIFUMI.reveal_param = {
            sessionId=current_session_id;
            roundId=1n;
            player_key=alice_chest_key;
            player_secret=alice_secret_1
        } in
        let _ = Test.transfer_to_contract_exn x (RevealPlay(reveal_args)) 0mutez in
        let session_0 : SHIFUMI.session = get_session_from_storage(addr, current_session_id) in
        let () = assert (session_0.current_round = 1n) in
        let () = assert (session_0.total_rounds = 1n) in
        let () = assert (session_0.result = Inplay) in
        let session_0_decoded_round_1 : SHIFUMI.decoded_player_actions = get_decoded_round_from_session(session_0, 1n) in
        let () = Test.log(session_0_decoded_round_1) in
        let count_ (acc, i: nat * SHIFUMI.decoded_player_action) : nat = acc + 1n in
        let nb_of_decoded_elements : nat = List.fold_left count_ 0n session_0_decoded_round_1 in
        let () = assert (nb_of_decoded_elements = 1n) in

        // bob reveals
        let () = Test.log("bob reveals in session 0 round 1") in
        let () = Test.set_source bob in
        let bob_reveal_args : SHIFUMI.reveal_param = {
            sessionId=current_session_id;
            roundId=1n;
            player_key=bob_chest_key;
            player_secret=bob_secret_1
        } in
        let _ = Test.transfer_to_contract_exn x (RevealPlay(bob_reveal_args)) 0mutez in
        let session_0 : SHIFUMI.session = get_session_from_storage(addr, current_session_id) in
        let session_0_decoded_round_1 : SHIFUMI.decoded_player_actions = get_decoded_round_from_session(session_0, 1n) in
        let () = Test.log(session_0_decoded_round_1) in
        let count_ (acc, i: nat * SHIFUMI.decoded_player_action) : nat = acc + 1n in
        let nb_of_decoded_elements : nat = List.fold_left count_ 0n session_0_decoded_round_1 in
        let () = assert (nb_of_decoded_elements = 2n) in
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
        //let () = Test.log(session_2) in
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
        //let () = Test.log(session_3) in
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
        let () = Test.set_now ("2022-02-22t10:00:00Z" : timestamp) in
        let session_args : SHIFUMI.createsession_param = { total_rounds=3n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.player set)) } in
        let current_session_id : nat = 4n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in
        
        // bob plays in (session=0n, round=1) 
        let () = Test.log("bob plays in session 4 round 1") in
        let () = Test.set_source bob in
        let () = Test.set_now ("2022-02-22t10:05:00Z" : timestamp) in
        let bob_payload_v : SHIFUMI.action = Paper in
        let bob_payload : bytes = Bytes.pack bob_payload_v in
        let bob_secret_1 : nat = 10n in 
        let (bob_chest,bob_chest_key) = Test.create_chest bob_payload bob_secret_1 in
        let play_args : SHIFUMI.play_param = {sessionId=current_session_id; roundId=1n; action=bob_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // bob stops session (session=4n) 
        let () = Test.log("bob stops session 4") in
        let () = Test.set_source bob in
        let () = Test.set_now ("2022-02-22t10:16:00Z" : timestamp) in
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
        let session_4 : SHIFUMI.session = match Map.find_opt current_session_id s2.sessions with
        | None -> failwith("could not find session 4")
        | Some sess -> sess 
        in
        let () = assert (session_4.result = Winner(bob)) in
        Test.log("test finished")
    in
    ()
