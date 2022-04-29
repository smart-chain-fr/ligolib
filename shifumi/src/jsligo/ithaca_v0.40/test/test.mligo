#import "../contracts/main.jsligo" "SHIFUMI"

let assert_string_failure (res : test_exec_result) (expected : string) : unit =
  let expected = Test.eval expected in
  match res with
  | Fail (Rejected (actual,_)) -> assert (Test.michelson_equal actual expected)
  | Fail (Balance_too_low p) -> failwith "contract failed: balance too low"
  | Fail (Other s) -> failwith s
  | Success _gas -> failwith "contract did not failed but was expected to fail"

let test =
    let () = Test.reset_state 3n ([] : tez list) in
    let alice: address = Test.nth_bootstrap_account 0 in
    let bob: address = Test.nth_bootstrap_account 1 in
    let james: address = Test.nth_bootstrap_account 2 in
    let init_storage : SHIFUMI.storage = { 
        next_session=0n;
        sessions=(Map.empty : (nat, SHIFUMI.Storage.Session.t) map)
    } in
    let (addr,_,_) = Test.originate SHIFUMI.main init_storage 0tez in
    let s_init = Test.get_storage addr in
    let () = Test.log(s_init) in


    let get_session_from_storage(contract_address, sessionId : (SHIFUMI.parameter, SHIFUMI.storage) typed_address * nat) : SHIFUMI.Storage.Session.t =
        let storage_with_session : SHIFUMI.Storage.t = Test.get_storage contract_address in
        let session_x : SHIFUMI.Storage.Session.t = match Map.find_opt sessionId storage_with_session.sessions with
        | None -> failwith("could not find session 0")
        | Some sess -> sess 
        in
        session_x
    in

    let get_round_from_session(sess, roundId : SHIFUMI.Storage.Session.t * nat) : SHIFUMI.Storage.Session.player_actions =
        let session_x_round_y : SHIFUMI.Storage.Session.player_actions = match Map.find_opt roundId sess.rounds with
        | None -> ([]: SHIFUMI.Storage.Session.player_actions)
        | Some pactions -> pactions
        in
        session_x_round_y
    in

    let get_decoded_round_from_session(sess, roundId : SHIFUMI.Storage.Session.t * nat) : SHIFUMI.Storage.Session.decoded_player_actions =
        let session_x_round_y : SHIFUMI.Storage.Session.decoded_player_actions = match Map.find_opt roundId sess.decoded_rounds with
        | None -> ([]: SHIFUMI.Storage.Session.decoded_player_actions)
        | Some pactions -> pactions
        in
        session_x_round_y
    in

    let session_0_complete_1_round_paper_stone = 
        let x : SHIFUMI.parameter contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session") in
        let () = Test.set_source alice in
        let session_args : SHIFUMI.Parameter.createsession_param = { total_rounds=1n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.Storage.Session.player set)) } in
        let current_session_id : nat = 0n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in
        // verify session creation
        let session_0 : SHIFUMI.Storage.Session.t = get_session_from_storage(addr, current_session_id) in
        let () = assert (session_0.current_round = 1n) in
        let () = assert (session_0.total_rounds = 1n) in
        let () = assert (session_0.result = Inplay) in
        let session_0_round_1 : SHIFUMI.Storage.Session.player_actions = get_round_from_session(session_0, 1n) in
        let count (acc, i: nat * SHIFUMI.Storage.Session.player_action) : nat = acc + 1n in
        let nb_of_elements : nat = List.fold_left count 0n session_0_round_1 in
        let () = assert (nb_of_elements = 0n) in
        let session_0_decoded_round_1 : SHIFUMI.Storage.Session.decoded_player_actions = get_decoded_round_from_session(session_0, 1n) in
        let count_ (acc, i: nat * SHIFUMI.Storage.Session.decoded_player_action) : nat = acc + 1n in
        let nb_of_decoded_elements : nat = List.fold count_ session_0_decoded_round_1 0n in
        let () = assert (nb_of_decoded_elements = 0n) in

        // bob plays in (session=0n, round=1) 
        let () = Test.log("bob plays in session 0 round 1") in
        let () = Test.set_source bob in
        let bob_payload_v : SHIFUMI.Storage.Session.action = Paper in
        let bob_payload : bytes = Bytes.pack bob_payload_v in
        let bob_secret_1 : nat = 10n in 
        let (bob_chest,bob_chest_key) = Test.create_chest bob_payload bob_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=bob_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in
        // verify round register bob chest
        let session_0 : SHIFUMI.Storage.Session.t = get_session_from_storage(addr, current_session_id) in
        let () = assert (session_0.current_round = 1n) in
        let () = assert (session_0.total_rounds = 1n) in
        let () = assert (session_0.result = Inplay) in
        let session_0_round_1 : SHIFUMI.Storage.Session.player_actions = get_round_from_session(session_0, 1n) in
        let count (acc, i: nat * SHIFUMI.Storage.Session.player_action) : nat = acc + 1n in
        let nb_of_elements : nat = List.fold_left count 0n session_0_round_1 in
        let () = assert (nb_of_elements = 1n) in
        let bob_action : SHIFUMI.Storage.Session.player_action = Option.unopt (List.head_opt session_0_round_1) in
        let () = assert (bob_action.player = bob) in
        // cannot compare chest
        //let () = assert (bob_action.action = bob_chest) in
        let session_0_decoded_round_1 : SHIFUMI.Storage.Session.decoded_player_actions = get_decoded_round_from_session(session_0, 1n) in
        let count_ (acc, i: nat * SHIFUMI.Storage.Session.decoded_player_action) : nat = acc + 1n in
        let nb_of_decoded_elements : nat = List.fold_left count_ 0n session_0_decoded_round_1 in
        let () = assert (nb_of_decoded_elements = 0n) in

        // alice plays in (session=0n, round=1) 
        let () = Test.log("alice plays in session 0 round 1") in
        let () = Test.set_source alice in
        let alice_payload_v : SHIFUMI.Storage.Session.action = Stone in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=alice_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in
        // verify round 1 register alice chest
        let session_0 : SHIFUMI.Storage.Session.t = get_session_from_storage(addr, current_session_id) in
        let () = assert (session_0.current_round = 1n) in
        let () = assert (session_0.total_rounds = 1n) in
        let () = assert (session_0.result = Inplay) in
        let session_0_round_1 : SHIFUMI.Storage.Session.player_actions = get_round_from_session(session_0, 1n) in
        let count (acc, i: nat * SHIFUMI.Storage.Session.player_action) : nat = acc + 1n in
        let nb_of_elements : nat = List.fold_left count 0n session_0_round_1 in
        let () = assert (nb_of_elements = 2n) in

        // alice reveals
        let () = Test.log("alice reveals in session 0 round 1") in
        let () = Test.set_source alice in
        let reveal_args : SHIFUMI.Parameter.reveal_param = {
            sessionId=current_session_id;
            roundId=1n;
            player_key=alice_chest_key;
            player_secret=alice_secret_1
        } in
        let _ = Test.transfer_to_contract_exn x (RevealPlay(reveal_args)) 0mutez in
        let session_0 : SHIFUMI.Storage.Session.t = get_session_from_storage(addr, current_session_id) in
        let () = assert (session_0.current_round = 1n) in
        let () = assert (session_0.total_rounds = 1n) in
        let () = assert (session_0.result = Inplay) in
        let session_0_decoded_round_1 : SHIFUMI.Storage.Session.decoded_player_actions = get_decoded_round_from_session(session_0, 1n) in
        let () = Test.log(session_0_decoded_round_1) in
        let count_ (acc, i: nat * SHIFUMI.Storage.Session.decoded_player_action) : nat = acc + 1n in
        let nb_of_decoded_elements : nat = List.fold_left count_ 0n session_0_decoded_round_1 in
        let () = assert (nb_of_decoded_elements = 1n) in

        // bob reveals
        let () = Test.log("bob reveals in session 0 round 1") in
        let () = Test.set_source bob in
        let bob_reveal_args : SHIFUMI.Parameter.reveal_param = {
            sessionId=current_session_id;
            roundId=1n;
            player_key=bob_chest_key;
            player_secret=bob_secret_1
        } in
        let _ = Test.transfer_to_contract_exn x (RevealPlay(bob_reveal_args)) 0mutez in
        let session_0 : SHIFUMI.Storage.Session.t = get_session_from_storage(addr, current_session_id) in
        let session_0_decoded_round_1 : SHIFUMI.Storage.Session.decoded_player_actions = get_decoded_round_from_session(session_0, 1n) in
        let () = Test.log(session_0_decoded_round_1) in
        let count_ (acc, i: nat * SHIFUMI.Storage.Session.decoded_player_action) : nat = acc + 1n in
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
        let x : SHIFUMI.parameter contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session") in
        let () = Test.set_source alice in
        let session_args : SHIFUMI.Parameter.createsession_param = { total_rounds=3n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.Storage.Session.player set)) } in
        //let () = Test.log(commit_args) in
        let current_session_id : nat = 1n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in

        // bob plays in (session=0n, round=1) 
        let () = Test.log("bob plays in session 1 round 1") in
        let () = Test.set_source bob in
        let bob_payload_v : SHIFUMI.Storage.Session.action = Paper in
        let bob_payload : bytes = Bytes.pack bob_payload_v in
        let bob_secret_1 : nat = 10n in 
        let (bob_chest,bob_chest_key) = Test.create_chest bob_payload bob_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=bob_chest} in
        //let () = Test.log(play_args) in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice plays in (session=0n, round=1) 
        let () = Test.log("alice plays in session 1 round 1") in
        let () = Test.set_source alice in
        let alice_payload_v : SHIFUMI.Storage.Session.action = Stone in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=alice_chest} in
        //let () = Test.log(play_args) in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in


        // alice reveals
        let () = Test.log("alice reveals in session 1 round 1") in
        let () = Test.set_source alice in
        let reveal_args : SHIFUMI.Parameter.reveal_param = {
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
        let bob_reveal_args : SHIFUMI.Parameter.reveal_param = {
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
        let s2 : SHIFUMI.Storage.t = Test.get_storage addr in
        //let () = Test.log(s2) in
        let session_1 : SHIFUMI.Storage.Session.t = match Map.find_opt current_session_id s2.sessions with
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
        let x : SHIFUMI.parameter contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session") in
        let () = Test.set_source alice in
        let session_args : SHIFUMI.Parameter.createsession_param = { total_rounds=1n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.Storage.Session.player set)) } in
        //let () = Test.log(commit_args) in
        let current_session_id : nat = 2n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in

        // bob plays in (session=0n, round=1) 
        let () = Test.log("bob plays in session 2 round 1") in
        let () = Test.set_source bob in
        let bob_payload_v : SHIFUMI.Storage.Session.action = Paper in
        let bob_payload : bytes = Bytes.pack bob_payload_v in
        let bob_secret_1 : nat = 10n in 
        let (bob_chest,bob_chest_key) = Test.create_chest bob_payload bob_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=bob_chest} in
        //let () = Test.log(play_args) in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice plays in (session=0n, round=1) 
        let () = Test.log("alice plays in session 2 round 1") in
        let () = Test.set_source alice in
        let alice_payload_v : SHIFUMI.Storage.Session.action = Paper in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=alice_chest} in
        //let () = Test.log(play_args) in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in


        // alice reveals
        let () = Test.log("alice reveals in session 2 round 1") in
        let () = Test.set_source alice in
        let reveal_args : SHIFUMI.Parameter.reveal_param = {
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
        let bob_reveal_args : SHIFUMI.Parameter.reveal_param = {
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
        let s2 : SHIFUMI.Storage.t = Test.get_storage addr in
        //let () = Test.log(s2) in
        let session_2 : SHIFUMI.Storage.Session.t = match Map.find_opt current_session_id s2.sessions with
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
        let x : SHIFUMI.parameter contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session") in
        let () = Test.set_source alice in
        let session_args : SHIFUMI.Parameter.createsession_param = { total_rounds=2n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.Storage.Session.player set)) } in
        //let () = Test.log(commit_args) in
        let current_session_id : nat = 3n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in

        // bob plays in (session=3n, round=1) 
        let () = Test.log("bob plays in session 3 round 1") in
        let () = Test.set_source bob in
        let bob_payload_v : SHIFUMI.Storage.Session.action = Paper in
        let bob_payload : bytes = Bytes.pack bob_payload_v in
        let bob_secret_1 : nat = 10n in 
        let (bob_chest,bob_chest_key) = Test.create_chest bob_payload bob_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=bob_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice plays in (session=3n, round=1) 
        let () = Test.log("alice plays in session 3 round 1") in
        let () = Test.set_source alice in
        let alice_payload_v : SHIFUMI.Storage.Session.action = Stone in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=alice_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice reveals in (session=3n, round=1) 
        let () = Test.log("alice reveals in session 3 round 1") in
        let () = Test.set_source alice in
        let reveal_args : SHIFUMI.Parameter.reveal_param = {
            sessionId=current_session_id;
            roundId=1n;
            player_key=alice_chest_key;
            player_secret=alice_secret_1
        } in
        let _ = Test.transfer_to_contract_exn x (RevealPlay(reveal_args)) 0mutez in

        // bob reveals in (session=3n, round=1) 
        let () = Test.log("bob reveals in session 3 round 1") in
        let () = Test.set_source bob in
        let bob_reveal_args : SHIFUMI.Parameter.reveal_param = {
            sessionId=current_session_id;
            roundId=1n;
            player_key=bob_chest_key;
            player_secret=bob_secret_1
        } in
        let _ = Test.transfer_to_contract_exn x (RevealPlay(bob_reveal_args)) 0mutez in

        // bob plays in (session=3n, round=2) 
        let () = Test.log("bob plays in session 3 round 2") in
        let () = Test.set_source bob in
        let bob_payload_v : SHIFUMI.Storage.Session.action = Stone in
        let bob_payload : bytes = Bytes.pack bob_payload_v in
        let bob_secret_1 : nat = 10n in 
        let (bob_chest,bob_chest_key) = Test.create_chest bob_payload bob_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=2n; action=bob_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice plays in (session=3n, round=2) 
        let () = Test.log("alice plays in session 3 round 2") in
        let () = Test.set_source alice in
        let alice_payload_v : SHIFUMI.Storage.Session.action = Paper in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=2n; action=alice_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice reveals in (session=3n, round=2) 
        let () = Test.log("alice reveals in session 3 round 2") in
        let () = Test.set_source alice in
        let reveal_args : SHIFUMI.Parameter.reveal_param = {
            sessionId=current_session_id;
            roundId=2n;
            player_key=alice_chest_key;
            player_secret=alice_secret_1
        } in
        let _ = Test.transfer_to_contract_exn x (RevealPlay(reveal_args)) 0mutez in

        // bob reveals in (session=3n, round=2) 
        let () = Test.log("bob reveals in session 3 round 2") in
        let () = Test.set_source bob in
        let bob_reveal_args : SHIFUMI.Parameter.reveal_param = {
            sessionId=current_session_id;
            roundId=2n;
            player_key=bob_chest_key;
            player_secret=bob_secret_1
        } in
        let _ = Test.transfer_to_contract_exn x (RevealPlay(bob_reveal_args)) 0mutez in

        // check storage
        let () = Test.log("check storage") in
        let s2 : SHIFUMI.Storage.t = Test.get_storage addr in
        //let () = Test.log(s2) in
        let session_3 : SHIFUMI.Storage.Session.t = match Map.find_opt current_session_id s2.sessions with
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
        let x : SHIFUMI.parameter contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let session_args : SHIFUMI.Parameter.createsession_param = { total_rounds=3n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.Storage.Session.player set)) } in
        let current_session_id : nat = 4n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in
        
        // bob plays in (session=0n, round=1) 
        let () = Test.log("bob plays in session 4 round 1") in
        let () = Test.set_source bob in
        let () = Test.bake_until_n_cycle_end 5n in
        let bob_payload_v : SHIFUMI.Storage.Session.action = Paper in
        let bob_payload : bytes = Bytes.pack bob_payload_v in
        let bob_secret_1 : nat = 10n in 
        let (bob_chest,bob_chest_key) = Test.create_chest bob_payload bob_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=bob_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // bob stops session (session=4n) 
        let () = Test.log("bob stops session 4") in
        let () = Test.set_source bob in
        let () = Test.bake_until_n_cycle_end 5n in
        let alice_payload_v : SHIFUMI.Storage.Session.action = Stone in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let stop_args : SHIFUMI.Parameter.stopsession_param = {sessionId=current_session_id} in
        //let () = Test.log(play_args) in
        let _ = Test.transfer_to_contract_exn x (StopSession(stop_args)) 0mutez in

        // check storage
        let () = Test.log("check storage") in
        let s2 : SHIFUMI.Storage.t = Test.get_storage addr in
        let session_4 : SHIFUMI.Storage.Session.t = match Map.find_opt current_session_id s2.sessions with
        | None -> failwith("could not find session 4")
        | Some sess -> sess 
        in
        let () = assert (session_4.result = Winner(bob)) in
        Test.log("test finished")
    in

    let session_5_stop_session_fail_unknown_session = 
        let x : SHIFUMI.parameter contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session 5") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let session_args : SHIFUMI.Parameter.createsession_param = { total_rounds=1n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.Storage.Session.player set)) } in
        let current_session_id : nat = 5n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in

        // verify session creation
        let session_0 : SHIFUMI.Storage.Session.t = get_session_from_storage(addr, current_session_id) in
        let () = assert (session_0.current_round = 1n) in
        let () = assert (session_0.total_rounds = 1n) in
        let () = assert (session_0.result = Inplay) in
        let session_0_round_1 : SHIFUMI.Storage.Session.player_actions = get_round_from_session(session_0, 1n) in
        let count (acc, i: nat * SHIFUMI.Storage.Session.player_action) : nat = acc + 1n in
        let nb_of_elements : nat = List.fold_left count 0n session_0_round_1 in
        let () = assert (nb_of_elements = 0n) in
        let session_0_decoded_round_1 : SHIFUMI.Storage.Session.decoded_player_actions = get_decoded_round_from_session(session_0, 1n) in
        let count_ (acc, i: nat * SHIFUMI.Storage.Session.decoded_player_action) : nat = acc + 1n in
        let nb_of_decoded_elements : nat = List.fold count_ session_0_decoded_round_1 0n in
        let () = assert (nb_of_decoded_elements = 0n) in

        // alice plays in (session=5n, round=1) 
        let () = Test.log("alice plays in session 5 round 1") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let alice_payload_v : SHIFUMI.Storage.Session.action = Stone in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=alice_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in
        // verify round 1 register alice chest
        let session_0 : SHIFUMI.Storage.Session.t = get_session_from_storage(addr, current_session_id) in
        let () = assert (session_0.current_round = 1n) in
        let () = assert (session_0.total_rounds = 1n) in
        let () = assert (session_0.result = Inplay) in
        let session_0_round_1 : SHIFUMI.Storage.Session.player_actions = get_round_from_session(session_0, 1n) in
        let count (acc, i: nat * SHIFUMI.Storage.Session.player_action) : nat = acc + 1n in
        let nb_of_elements : nat = List.fold_left count 0n session_0_round_1 in
        let () = assert (nb_of_elements = 1n) in

        // alice stops session (session=99n) 
        let () = Test.log("bob stops session 99") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let bad_session_id : nat = 99n in
        let stop_args : SHIFUMI.Parameter.stopsession_param = {sessionId=bad_session_id} in
        let fail_stop_session = Test.transfer_to_contract x (StopSession(stop_args)) 0mutez in
        assert_string_failure fail_stop_session SHIFUMI.Errors.unknown_session
    in
    let session_6_stop_session_fail_too_early = 
        let x : SHIFUMI.parameter contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session 6") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let session_args : SHIFUMI.Parameter.createsession_param = { total_rounds=1n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.Storage.Session.player set)) } in
        let current_session_id : nat = 6n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in

        // alice plays in (session=6n, round=1) 
        let () = Test.log("alice plays in session 6 round 1") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let alice_payload_v : SHIFUMI.Storage.Session.action = Stone in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=alice_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice stops session (session=6n) 
        let () = Test.log("alice stops session 6") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 1n in
        let stop_args : SHIFUMI.Parameter.stopsession_param = {sessionId=current_session_id} in
        let fail_stop_session = Test.transfer_to_contract x (StopSession(stop_args)) 0mutez in
        let () = Test.bake_until_n_cycle_end 1n in
        assert_string_failure fail_stop_session SHIFUMI.Errors.must_wait_10_min
    in
    let session_7_stop_session_fail_unauthorized_user = 
        let x : SHIFUMI.parameter contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session 7") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let session_args : SHIFUMI.Parameter.createsession_param = { total_rounds=1n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.Storage.Session.player set)) } in
        let current_session_id : nat = 7n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in

        // alice plays in (session=7n, round=1) 
        let () = Test.log("alice plays in session 7 round 1") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let alice_payload_v : SHIFUMI.Storage.Session.action = Stone in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=alice_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // james stops session (session=7n) 
        let () = Test.log("alice stops session 7") in
        let () = Test.set_source james in
        let () = Test.bake_until_n_cycle_end 5n in
        let stop_args : SHIFUMI.Parameter.stopsession_param = {sessionId=current_session_id} in
        let fail_stop_session = Test.transfer_to_contract x (StopSession(stop_args)) 0mutez in
        assert_string_failure fail_stop_session SHIFUMI.Errors.user_not_allowed_to_stop_session
    in
    let session_8_stop_session_fail_session_finished = 
        let x : SHIFUMI.parameter contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session 8") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let session_args : SHIFUMI.Parameter.createsession_param = { total_rounds=1n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.Storage.Session.player set)) } in
        let current_session_id : nat = 8n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in

        // bob plays in (session=8n, round=1) 
        let () = Test.log("bob plays in session 8 round 1") in
        let () = Test.set_source bob in
        let () = Test.bake_until_n_cycle_end 5n in
        let bob_payload_v : SHIFUMI.Storage.Session.action = Paper in
        let bob_payload : bytes = Bytes.pack bob_payload_v in
        let bob_secret_1 : nat = 10n in 
        let (bob_chest,bob_chest_key) = Test.create_chest bob_payload bob_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=bob_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice plays in (session=8n, round=1) 
        let () = Test.log("alice plays in session 8 round 1") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let alice_payload_v : SHIFUMI.Storage.Session.action = Stone in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=alice_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice reveals
        let () = Test.log("alice reveals in session 8 round 1") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let reveal_args : SHIFUMI.Parameter.reveal_param = {
            sessionId=current_session_id;
            roundId=1n;
            player_key=alice_chest_key;
            player_secret=alice_secret_1
        } in
        let _ = Test.transfer_to_contract_exn x (RevealPlay(reveal_args)) 0mutez in

        // bob reveals
        let () = Test.log("bob reveals in session 8 round 1") in
        let () = Test.set_source bob in
        let () = Test.bake_until_n_cycle_end 5n in
        let bob_reveal_args : SHIFUMI.Parameter.reveal_param = {
            sessionId=current_session_id;
            roundId=1n;
            player_key=bob_chest_key;
            player_secret=bob_secret_1
        } in
        let _ = Test.transfer_to_contract_exn x (RevealPlay(bob_reveal_args)) 0mutez in

        // bob stops session (session=8n) 
        let () = Test.log("bob stops session 8") in
        let () = Test.set_source bob in
        let () = Test.bake_until_n_cycle_end 5n in
        let stop_args : SHIFUMI.Parameter.stopsession_param = {sessionId=current_session_id} in
        let fail_stop_session = Test.transfer_to_contract x (StopSession(stop_args)) 0mutez in
        //Test.log(fail_stop_session)
        assert_string_failure fail_stop_session SHIFUMI.Errors.session_finished

    in
    let session_9_play_fail_unauthorized_user = 
        let x : SHIFUMI.parameter contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session 9") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let session_args : SHIFUMI.Parameter.createsession_param = { total_rounds=1n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.Storage.Session.player set)) } in
        let current_session_id : nat = 9n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in

        // james plays in (session=9n, round=1) 
        let () = Test.log("alice plays in session 9 round 1") in
        let () = Test.set_source james in
        let () = Test.bake_until_n_cycle_end 5n in
        let james_payload_v : SHIFUMI.Storage.Session.action = Stone in
        let james_payload : bytes = Bytes.pack james_payload_v in
        let james_secret_1 : nat = 654843n in 
        let (james_chest,james_chest_key) = Test.create_chest james_payload james_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=james_chest} in
        let fail_play = Test.transfer_to_contract x (Play(play_args)) 0mutez in
        assert_string_failure fail_play SHIFUMI.Errors.user_not_allowed_to_play_in_session
    in
    let session_10_play_fail_unknown_session = 
        let x : SHIFUMI.parameter contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session 10") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let session_args : SHIFUMI.Parameter.createsession_param = { total_rounds=1n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.Storage.Session.player set)) } in
        let current_session_id : nat = 10n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in

        // alice plays in (session=10n, round=1) 
        let () = Test.log("alice plays in session 99 round 1") in
        let bad_session_id : nat = 99n in 
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let alice_payload_v : SHIFUMI.Storage.Session.action = Stone in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=bad_session_id; roundId=1n; action=alice_chest} in
        let fail_play = Test.transfer_to_contract x (Play(play_args)) 0mutez in
        assert_string_failure fail_play SHIFUMI.Errors.unknown_session
    in
    let session_11_play_fail_wrong_current_round = 
        let x : SHIFUMI.parameter contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session 11") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let session_args : SHIFUMI.Parameter.createsession_param = { total_rounds=1n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.Storage.Session.player set)) } in
        let current_session_id : nat = 11n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in

        // alice plays in (session=11n, round=1) 
        let () = Test.log("alice plays in session 11 round 2") in
        let bad_round_id : nat = 2n in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let alice_payload_v : SHIFUMI.Storage.Session.action = Stone in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=bad_round_id; action=alice_chest} in
        let fail_play = Test.transfer_to_contract x (Play(play_args)) 0mutez in
        assert_string_failure fail_play SHIFUMI.Errors.wrong_current_round
    in
    let session_12_play_fail_already_played = 
        let x : SHIFUMI.parameter contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session 12") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let session_args : SHIFUMI.Parameter.createsession_param = { total_rounds=1n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.Storage.Session.player set)) } in
        let current_session_id : nat = 12n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in

        // alice plays in (session=12n, round=1) 
        let () = Test.log("alice plays in session 12 round 1") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let alice_payload_v : SHIFUMI.Storage.Session.action = Stone in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=alice_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice plays in (session=12n, round=1) 
        let () = Test.log("alice plays in session 12 round 1") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let alice_payload_v2 : SHIFUMI.Storage.Session.action = Stone in
        let alice_payload2 : bytes = Bytes.pack alice_payload_v2 in
        let alice_secret_2 : nat = 357924n in 
        let (alice_chest2,alice_chest_key2) = Test.create_chest alice_payload2 alice_secret_2 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=alice_chest2} in
        let fail_play = Test.transfer_to_contract x (Play(play_args)) 0mutez in
        assert_string_failure fail_play SHIFUMI.Errors.user_already_played
    in
    let session_13_reveal_fail_unknown_session = 
        let x : SHIFUMI.parameter contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session 13") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let session_args : SHIFUMI.Parameter.createsession_param = { total_rounds=1n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.Storage.Session.player set)) } in
        let current_session_id : nat = 13n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in

        // bob plays in (session=8n, round=1) 
        let () = Test.log("bob plays in session 13 round 1") in
        let () = Test.set_source bob in
        let () = Test.bake_until_n_cycle_end 5n in
        let bob_payload_v : SHIFUMI.Storage.Session.action = Paper in
        let bob_payload : bytes = Bytes.pack bob_payload_v in
        let bob_secret_1 : nat = 10n in 
        let (bob_chest,bob_chest_key) = Test.create_chest bob_payload bob_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=bob_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice plays in (session=8n, round=1) 
        let () = Test.log("alice plays in session 13 round 1") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let alice_payload_v : SHIFUMI.Storage.Session.action = Stone in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=alice_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice reveals
        let () = Test.log("alice reveals in session 99 round 1") in
        let bad_session_id : nat = 99n in 
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let reveal_args : SHIFUMI.Parameter.reveal_param = {
            sessionId=bad_session_id;
            roundId=1n;
            player_key=alice_chest_key;
            player_secret=alice_secret_1
        } in
        let fail_reveal = Test.transfer_to_contract x (RevealPlay(reveal_args)) 0mutez in
        assert_string_failure fail_reveal SHIFUMI.Errors.unknown_session
    in

    let session_14_reveal_fail_unauthorized_user = 
        let x : SHIFUMI.parameter contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session 14") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let session_args : SHIFUMI.Parameter.createsession_param = { total_rounds=1n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.Storage.Session.player set)) } in
        let current_session_id : nat = 14n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in

        // bob plays in (session=14n, round=1) 
        let () = Test.log("bob plays in session 14 round 1") in
        let () = Test.set_source bob in
        let () = Test.bake_until_n_cycle_end 5n in
        let bob_payload_v : SHIFUMI.Storage.Session.action = Paper in
        let bob_payload : bytes = Bytes.pack bob_payload_v in
        let bob_secret_1 : nat = 10n in 
        let (bob_chest,bob_chest_key) = Test.create_chest bob_payload bob_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=bob_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice plays in (session=14n, round=1) 
        let () = Test.log("alice plays in session 14 round 1") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let alice_payload_v : SHIFUMI.Storage.Session.action = Stone in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=alice_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // james reveals
        let () = Test.log("james reveals in session 14 round 1") in
        let () = Test.set_source james in
        let () = Test.bake_until_n_cycle_end 5n in
        let reveal_args : SHIFUMI.Parameter.reveal_param = {
            sessionId=current_session_id;
            roundId=1n;
            player_key=alice_chest_key;
            player_secret=alice_secret_1
        } in
        let fail_reveal = Test.transfer_to_contract x (RevealPlay(reveal_args)) 0mutez in
        assert_string_failure fail_reveal SHIFUMI.Errors.user_not_allowed_to_reveal_in_session
    in
    let session_15_reveal_fail_wrong_current_round = 
        let x : SHIFUMI.parameter contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session 15") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let session_args : SHIFUMI.Parameter.createsession_param = { total_rounds=1n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.Storage.Session.player set)) } in
        let current_session_id : nat = 15n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in

        // bob plays in (session=8n, round=1) 
        let () = Test.log("bob plays in session 15 round 1") in
        let () = Test.set_source bob in
        let () = Test.bake_until_n_cycle_end 5n in
        let bob_payload_v : SHIFUMI.Storage.Session.action = Paper in
        let bob_payload : bytes = Bytes.pack bob_payload_v in
        let bob_secret_1 : nat = 10n in 
        let (bob_chest,bob_chest_key) = Test.create_chest bob_payload bob_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=bob_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice plays in (session=8n, round=1) 
        let () = Test.log("alice plays in session 15 round 1") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let alice_payload_v : SHIFUMI.Storage.Session.action = Stone in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=alice_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice reveals
        let () = Test.log("alice reveals in session 15 round 1") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let reveal_args : SHIFUMI.Parameter.reveal_param = {
            sessionId=current_session_id;
            roundId=1n;
            player_key=alice_chest_key;
            player_secret=alice_secret_1
        } in
        let _ = Test.transfer_to_contract_exn x (RevealPlay(reveal_args)) 0mutez in

        // bob reveals
        let () = Test.log("bob reveals in session 15 round 1") in
        let bad_round_id : nat = 99n in
        let () = Test.set_source bob in
        let () = Test.bake_until_n_cycle_end 5n in
        let bob_reveal_args : SHIFUMI.Parameter.reveal_param = {
            sessionId=current_session_id;
            roundId=bad_round_id;
            player_key=bob_chest_key;
            player_secret=bob_secret_1
        } in
        let fail_reveal = Test.transfer_to_contract x (RevealPlay(bob_reveal_args)) 0mutez in
        assert_string_failure fail_reveal SHIFUMI.Errors.wrong_current_round
    in
    let session_16_reveal_fail_missing_chest = 
        let x : SHIFUMI.parameter contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session 16") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let session_args : SHIFUMI.Parameter.createsession_param = { total_rounds=1n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.Storage.Session.player set)) } in
        let current_session_id : nat = 16n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in

        // bob plays in (session=16n, round=1) 
        let () = Test.log("bob plays in session 16 round 1") in
        let () = Test.set_source bob in
        let () = Test.bake_until_n_cycle_end 5n in
        let bob_payload_v : SHIFUMI.Storage.Session.action = Paper in
        let bob_payload : bytes = Bytes.pack bob_payload_v in
        let bob_secret_1 : nat = 10n in 
        let (bob_chest,bob_chest_key) = Test.create_chest bob_payload bob_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=bob_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // bob reveals
        let () = Test.log("bob reveals in session 16 round 1") in
        let () = Test.set_source bob in
        let () = Test.bake_until_n_cycle_end 5n in
        let bob_reveal_args : SHIFUMI.Parameter.reveal_param = {
            sessionId=current_session_id;
            roundId=1n;
            player_key=bob_chest_key;
            player_secret=bob_secret_1
        } in
        let fail_reveal = Test.transfer_to_contract x (RevealPlay(bob_reveal_args)) 0mutez in
        assert_string_failure fail_reveal SHIFUMI.Errors.missing_player_chest
    in
    let session_17_reveal_fail_missing_all_chests = 
        let x : SHIFUMI.parameter contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session 17") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let session_args : SHIFUMI.Parameter.createsession_param = { total_rounds=1n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.Storage.Session.player set)) } in
        let current_session_id : nat = 17n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in

        // bob create its chest but do not play in (session=17n, round=1) 
        let () = Test.log("bob plays in session 17 round 1") in
        let () = Test.set_source bob in
        let () = Test.bake_until_n_cycle_end 5n in
        let bob_payload_v : SHIFUMI.Storage.Session.action = Paper in
        let bob_payload : bytes = Bytes.pack bob_payload_v in
        let bob_secret_1 : nat = 10n in 
        let (bob_chest,bob_chest_key) = Test.create_chest bob_payload bob_secret_1 in

        // bob reveals
        let () = Test.log("bob reveals in session 17 round 1") in
        let () = Test.set_source bob in
        let () = Test.bake_until_n_cycle_end 5n in
        let bob_reveal_args : SHIFUMI.Parameter.reveal_param = {
            sessionId=current_session_id;
            roundId=1n;
            player_key=bob_chest_key;
            player_secret=bob_secret_1
        } in
        let fail_reveal = Test.transfer_to_contract x (RevealPlay(bob_reveal_args)) 0mutez in
        assert_string_failure fail_reveal SHIFUMI.Errors.missing_all_chests
    in
    let session_18_reveal_fail_open_chest_timelock = 
        let x : SHIFUMI.parameter contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session 18") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let session_args : SHIFUMI.Parameter.createsession_param = { total_rounds=1n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.Storage.Session.player set)) } in
        let current_session_id : nat = 18n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in

        // bob plays in (session=8n, round=1) 
        let () = Test.log("bob plays in session 18 round 1") in
        let () = Test.set_source bob in
        let () = Test.bake_until_n_cycle_end 5n in
        let bob_payload_v : SHIFUMI.Storage.Session.action = Paper in
        let bob_payload : bytes = Bytes.pack bob_payload_v in
        let bob_secret_1 : nat = 10n in 
        let (bob_chest,bob_chest_key) = Test.create_chest bob_payload bob_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=bob_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice plays in (session=8n, round=1) 
        let () = Test.log("alice plays in session 18 round 1") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let alice_payload_v : SHIFUMI.Storage.Session.action = Stone in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=alice_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice reveals
        let () = Test.log("alice reveals in session 18 round 1") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let reveal_args : SHIFUMI.Parameter.reveal_param = {
            sessionId=current_session_id;
            roundId=1n;
            player_key=alice_chest_key;
            player_secret=alice_secret_1
        } in
        let _ = Test.transfer_to_contract_exn x (RevealPlay(reveal_args)) 0mutez in

        // bob reveals
        let () = Test.log("bob reveals in session 18 round 1") in
        let () = Test.set_source bob in
        let () = Test.bake_until_n_cycle_end 5n in
        let bad_secret_bob : nat = 11n in
        let bob_reveal_args : SHIFUMI.Parameter.reveal_param = {
            sessionId=current_session_id;
            roundId=1n;
            player_key=bob_chest_key;
            player_secret=bad_secret_bob
        } in
        let fail_reveal = Test.transfer_to_contract x (RevealPlay(bob_reveal_args)) 0mutez in
        assert_string_failure fail_reveal SHIFUMI.Errors.failed_to_open_chest
    in
    let session_19_reveal_fail_open_chest_key = 
        let x : SHIFUMI.parameter contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session 19") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let session_args : SHIFUMI.Parameter.createsession_param = { total_rounds=1n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.Storage.Session.player set)) } in
        let current_session_id : nat = 19n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in

        // bob plays in (session=19n, round=1) 
        let () = Test.log("bob plays in session 19 round 1") in
        let () = Test.set_source bob in
        let () = Test.bake_until_n_cycle_end 5n in
        let bob_payload_v : SHIFUMI.Storage.Session.action = Paper in
        let bob_payload : bytes = Bytes.pack bob_payload_v in
        let bob_secret_1 : nat = 10n in 
        let (bob_chest,bob_chest_key) = Test.create_chest bob_payload bob_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=bob_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice plays in (session=19n, round=1) 
        let () = Test.log("alice plays in session 19 round 1") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let alice_payload_v : SHIFUMI.Storage.Session.action = Stone in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=alice_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice reveals
        let () = Test.log("alice reveals in session 19 round 1") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let reveal_args : SHIFUMI.Parameter.reveal_param = {
            sessionId=current_session_id;
            roundId=1n;
            player_key=alice_chest_key;
            player_secret=alice_secret_1
        } in
        let _ = Test.transfer_to_contract_exn x (RevealPlay(reveal_args)) 0mutez in

        // bob reveals
        let () = Test.log("bob reveals in session 19 round 1") in
        let () = Test.set_source bob in
        let () = Test.bake_until_n_cycle_end 5n in

        let bob_payload_v2 : SHIFUMI.Storage.Session.action = Paper in
        let bob_payload2 : bytes = Bytes.pack bob_payload_v2 in
        let bob_secret_2 : nat = 10n in 
        let (bob_chest2,bob_chest_key2) = Test.create_chest bob_payload2 bob_secret_2 in

        let bob_reveal_args : SHIFUMI.Parameter.reveal_param = {
            sessionId=current_session_id;
            roundId=1n;
            player_key=bob_chest_key2;
            player_secret=bob_secret_1
        } in
        let fail_reveal = Test.transfer_to_contract x (RevealPlay(bob_reveal_args)) 0mutez in
        assert_string_failure fail_reveal SHIFUMI.Errors.failed_to_open_chest
    in
    let session_20_reveal_fail_already_revealed = 
        let x : SHIFUMI.parameter contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session 20") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let session_args : SHIFUMI.Parameter.createsession_param = { total_rounds=1n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.Storage.Session.player set)) } in
        let current_session_id : nat = 20n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in

        // bob plays in (session=20n, round=1) 
        let () = Test.log("bob plays in session 20 round 1") in
        let () = Test.set_source bob in
        let () = Test.bake_until_n_cycle_end 5n in
        let bob_payload_v : SHIFUMI.Storage.Session.action = Paper in
        let bob_payload : bytes = Bytes.pack bob_payload_v in
        let bob_secret_1 : nat = 10n in 
        let (bob_chest,bob_chest_key) = Test.create_chest bob_payload bob_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=bob_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice plays in (session=20n, round=1) 
        let () = Test.log("alice plays in session 20 round 1") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let alice_payload_v : SHIFUMI.Storage.Session.action = Stone in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=alice_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // bob reveals
        let () = Test.log("bob reveals in session 20 round 1") in
        let () = Test.set_source bob in
        let () = Test.bake_until_n_cycle_end 5n in
        let bob_reveal_args : SHIFUMI.Parameter.reveal_param = {
            sessionId=current_session_id;
            roundId=1n;
            player_key=bob_chest_key;
            player_secret=bob_secret_1
        } in
        let _ = Test.transfer_to_contract x (RevealPlay(bob_reveal_args)) 0mutez in

        // bob reveals
        let () = Test.log("bob reveals in session 20 round 1") in
        let () = Test.set_source bob in
        let () = Test.bake_until_n_cycle_end 5n in
        let bob_reveal_args : SHIFUMI.Parameter.reveal_param = {
            sessionId=current_session_id;
            roundId=1n;
            player_key=bob_chest_key;
            player_secret=bob_secret_1
        } in
        let fail_reveal = Test.transfer_to_contract x (RevealPlay(bob_reveal_args)) 0mutez in
        assert_string_failure fail_reveal SHIFUMI.Errors.user_already_revealed
    in
    let session_21_reveal_fail_session_finished = 
        let x : SHIFUMI.parameter contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session 21") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let session_args : SHIFUMI.Parameter.createsession_param = { total_rounds=1n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.Storage.Session.player set)) } in
        let current_session_id : nat = 21n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in

        // bob plays in (session=20n, round=1) 
        let () = Test.log("bob plays in session 21 round 1") in
        let () = Test.set_source bob in
        let () = Test.bake_until_n_cycle_end 5n in
        let bob_payload_v : SHIFUMI.Storage.Session.action = Paper in
        let bob_payload : bytes = Bytes.pack bob_payload_v in
        let bob_secret_1 : nat = 10n in 
        let (bob_chest,bob_chest_key) = Test.create_chest bob_payload bob_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=bob_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice plays in (session=20n, round=1) 
        let () = Test.log("alice plays in session 21 round 1") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let alice_payload_v : SHIFUMI.Storage.Session.action = Stone in
        let alice_payload : bytes = Bytes.pack alice_payload_v in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=alice_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice reveals
        let () = Test.log("alice reveals in session 21 round 1") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let reveal_args : SHIFUMI.Parameter.reveal_param = {
            sessionId=current_session_id;
            roundId=1n;
            player_key=alice_chest_key;
            player_secret=alice_secret_1
        } in
        let _ = Test.transfer_to_contract_exn x (RevealPlay(reveal_args)) 0mutez in

        // bob reveals
        let () = Test.log("bob reveals in session 21 round 1") in
        let () = Test.set_source bob in
        let () = Test.bake_until_n_cycle_end 5n in
        let bob_reveal_args : SHIFUMI.Parameter.reveal_param = {
            sessionId=current_session_id;
            roundId=1n;
            player_key=bob_chest_key;
            player_secret=bob_secret_1
        } in
        let _ = Test.transfer_to_contract x (RevealPlay(bob_reveal_args)) 0mutez in

        // bob reveals a second time
        let () = Test.log("bob reveals in session 21 round 1") in
        let () = Test.set_source bob in
        let () = Test.bake_until_n_cycle_end 5n in
        let bob_reveal_args : SHIFUMI.Parameter.reveal_param = {
            sessionId=current_session_id;
            roundId=1n;
            player_key=bob_chest_key;
            player_secret=bob_secret_1
        } in
        let fail_reveal = Test.transfer_to_contract x (RevealPlay(bob_reveal_args)) 0mutez in
        assert_string_failure fail_reveal SHIFUMI.Errors.session_finished
    in
    let session_22_reveal_fail_session_finished = 
        let x : SHIFUMI.parameter contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session 22") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let session_args : SHIFUMI.Parameter.createsession_param = { total_rounds=1n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.Storage.Session.player set)) } in
        let current_session_id : nat = 22n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in

        // bob plays in (session=22n, round=1) 
        let () = Test.log("bob plays in session 22 round 1") in
        let () = Test.set_source bob in
        let () = Test.bake_until_n_cycle_end 5n in
        let bob_payload_v : SHIFUMI.Storage.Session.action = Paper in
        let bob_payload : bytes = Bytes.pack bob_payload_v in
        let bob_secret_1 : nat = 10n in 
        let (bob_chest,bob_chest_key) = Test.create_chest bob_payload bob_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=bob_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice plays in (session=22n, round=1) 
        let () = Test.log("alice plays in session 22 round 1") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        //let alice_payload_v : SHIFUMI.Storage.Session.action = Stone in
        let alice_payload_str : string = "Stone" in
        let alice_payload : bytes = Bytes.pack alice_payload_str in
        let alice_secret_1 : nat = 654843n in 
        let (alice_chest,alice_chest_key) = Test.create_chest alice_payload alice_secret_1 in
        let play_args : SHIFUMI.Parameter.play_param = {sessionId=current_session_id; roundId=1n; action=alice_chest} in
        let _ = Test.transfer_to_contract_exn x (Play(play_args)) 0mutez in

        // alice reveals
        let () = Test.log("alice reveals in session 22 round 1") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let reveal_args : SHIFUMI.Parameter.reveal_param = {
            sessionId=current_session_id;
            roundId=1n;
            player_key=alice_chest_key;
            player_secret=alice_secret_1
        } in
        let fail_reveal = Test.transfer_to_contract x (RevealPlay(reveal_args)) 0mutez in
        assert_string_failure fail_reveal SHIFUMI.Errors.failed_to_unpack_payload
    in
    let session_23_stop_session_all_troller = 
        let x : SHIFUMI.parameter contract = Test.to_contract addr in

        // alice create session
        let () = Test.log("alice create session 23") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let session_args : SHIFUMI.Parameter.createsession_param = { total_rounds=1n; players=Set.add alice (Set.add bob (Set.empty : SHIFUMI.Storage.Session.player set)) } in
        let current_session_id : nat = 23n in
        let _ = Test.transfer_to_contract_exn x (CreateSession(session_args)) 0mutez in

        // alice stops session (session=23n) 
        let () = Test.log("alice stops session 23") in
        let () = Test.set_source alice in
        let () = Test.bake_until_n_cycle_end 5n in
        let stop_args : SHIFUMI.Parameter.stopsession_param = {sessionId=current_session_id} in
        let fail_stop_session = Test.transfer_to_contract x (StopSession(stop_args)) 0mutez in
        assert_string_failure fail_stop_session SHIFUMI.Errors.no_winner
    in

    ()
