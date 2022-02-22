#import "errors.mligo" "Errors"
#import "parameter.mligo" "Parameter"
#import "session.mligo" "Session"

module Types = struct

    type t = {
        next_session : nat;
        sessions : (nat, Session.Types.t) map
    }
end


module Utils = struct

    let createSession(param, store : Parameter.Types.createsession_param * Types.t) : operation list * Types.t = 
        let new_session : Session.Types.t = { asleep=Tezos.now + 600; total_rounds=param.total_rounds; players=param.players; current_round=1n; rounds=(Map.empty : (Session.Types.round, Session.Types.player_actions) map); decoded_rounds=(Map.empty : (Session.Types.round, Session.Types.decoded_player_actions) map); board=(Map.empty : Session.Types.board); result=Inplay } in
        let new_storage : Types.t = { next_session=store.next_session + 1n; sessions=Map.add store.next_session new_session store.sessions} in
        (([]: operation list), new_storage)

    let stopSession(param, store : Parameter.Types.stopsession_param * Types.t) : operation list * Types.t = 
        let current_session : Session.Types.t = match Map.find_opt param.sessionId store.sessions with
        | None -> (failwith("Unknown session") : Session.Types.t)
        | Some (sess) -> sess
        in
        let _check_asleep : unit = assert_with_error (Tezos.now > current_session.asleep) "Must wait at least 600 seconds before claiming Victory (in case opponent is not playing)" in
        let _check_players : unit = assert_with_error (Set.mem Tezos.sender current_session.players) "Not allowed to stop this session" in
        let _check_session_end : unit = assert_with_error (current_session.result = (Inplay : Session.Types.result)) "this session is finished" in
        let current_round = match Map.find_opt current_session.current_round current_session.rounds with
        | None -> (failwith("SHOULD NOT BE HERE SESSION IS BROKEN") : Session.Types.player_actions)
        | Some rnd -> rnd 
        in
        let missing_players = Session.Utils.find_missing_players(current_round, current_session.players) in
        if Set.size missing_players > 0n then
            let rem_player(acc, elt : address set * address ) : address set = Set.remove elt acc in
            let winners_set : address set = Set.fold rem_player missing_players current_session.players in
            let add_player(acc, elt : address list * address) : address list = elt :: acc in
            let winners_list : address list = Set.fold add_player winners_set ([] : address list) in
            let winner : address = Option.unopt (List.head_opt winners_list) in
            let new_current_session : Session.Types.t = { current_session with result=Winner(winner) } in
            let new_storage : Types.t = { store with sessions=Map.update param.sessionId (Some(new_current_session)) store.sessions} in 
            (([]: operation list), new_storage )
        else
            let current_decoded_round = match Map.find_opt current_session.current_round current_session.decoded_rounds with
            | None -> (failwith("SHOULD NOT BE HERE SESSION IS BROKEN") : Session.Types.decoded_player_actions)
            | Some rnd -> rnd 
            in
            let missing_players_for_reveal = Session.Utils.find_missing_players_for_reveal(current_decoded_round, current_session.players) in
            if Set.size missing_players_for_reveal > 0n then
                let rem_player(acc, elt : address set * address ) : address set = Set.remove elt acc in
                let winners_set : address set = Set.fold rem_player missing_players_for_reveal current_session.players in
                let add_player(acc, elt : address list * address) : address list = elt :: acc in
                let winners_list : address list = Set.fold add_player winners_set ([] : address list) in
                let winner : address = Option.unopt (List.head_opt winners_list) in
                let new_current_session : Session.Types.t = { current_session with result=Winner(winner) } in
                let new_storage : Types.t = { store with sessions=Map.update param.sessionId (Some(new_current_session)) store.sessions} in 
                (([]: operation list), new_storage )
            else
                (([]: operation list), store )


    // the player create a chest with the chosen action (Stone | Paper | Cisor) in backend
    // once the chest is created, the player send its chest to the smart contract
    let play(param, store : Parameter.Types.play_param * Types.t) : operation list * Types.t = 
        let current_session : Session.Types.t = match Map.find_opt param.sessionId store.sessions with
        | None -> (failwith("Unknown session") : Session.Types.t)
        | Some (sess) -> sess
        in
        let _check_players : unit = assert_with_error (Set.mem Tezos.sender current_session.players) "Not allowed to play in this session" in
        let _check_round : unit = assert_with_error (current_session.current_round = param.roundId) "Wrong round parameter" in
        // register action
        let new_rounds = match Map.find_opt current_session.current_round current_session.rounds with 
        | None -> Map.add current_session.current_round [{player=Tezos.sender; action=param.action}] current_session.rounds
        | Some (playerActions) ->
            let _check_player_has_played_this_round = assert_with_error (Session.Utils.has_played(current_session, param.roundId, Tezos.sender) = false) "You already have played for this round" in
            Map.update current_session.current_round (Some({player=Tezos.sender; action=param.action} :: playerActions)) current_session.rounds
        in
        let new_current_session : Session.Types.t = { current_session with asleep=Tezos.now + 600; rounds=new_rounds } in
        let new_storage : Types.t = { store with sessions=Map.update param.sessionId (Some(new_current_session)) store.sessions} in 
        (([]: operation list), new_storage)

    let reveal (param, store : Parameter.Types.reveal_param * Types.t) : operation list * Types.t =
        // players can reveal only if all players have sent their chest
        let current_session : Session.Types.t = match Map.find_opt param.sessionId store.sessions with
        | None -> (failwith("Unknown session") : Session.Types.t)
        | Some (sess) -> sess
        in
        let _check_players : unit = assert_with_error (Set.mem Tezos.sender current_session.players) "Not allowed to play in this session" in
        let _check_round : unit = assert_with_error (current_session.current_round = param.roundId) "Wrong round parameter" in
        let current_round_actions : Session.Types.player_actions = match Map.find_opt current_session.current_round current_session.rounds with 
        | None -> failwith("no actions registered")
        | Some (round_actions) -> round_actions 
        in
        let numberOfPlayers : nat = Set.size current_session.players in
        let listsize (acc, _elt: nat * Session.Types.player_action) : nat = acc + 1n in 
        let numberOfActions : nat = List.fold listsize current_round_actions 0n in 
        let _check_all_players_have_played : unit = assert_with_error (numberOfPlayers = numberOfActions) "a player has not played" in

        let rec find_chest(addr, lst_opt : address * Session.Types.player_actions option) : chest option =
            match lst_opt with
            | None -> (None : chest option)
            | Some lst -> (match List.head_opt lst with
                | None -> (None : chest option) 
                | Some elt -> if (elt.player = addr) then
                        (Some(elt.action) : chest option)
                    else
                        find_chest(addr, (List.tail_opt lst)))
        in
        let user_chest : chest = match find_chest(Tezos.sender, (Some(current_round_actions))) with
        | None -> (failwith("Missing chest") : chest)
        | Some ch -> ch
        in
        // decode action
        let decoded_payload =
            match Tezos.open_chest param.player_key user_chest param.player_secret with
            | Ok_opening b -> b
            | Fail_timelock -> (failwith("Failed to open chest") : bytes)
            | Fail_decrypt -> (failwith("Failed to open chest") : bytes)
        in
        let decoded_action : Session.Types.action = match (Bytes.unpack decoded_payload : Session.Types.action option) with
        | None -> failwith("Failed to unpack the payload")
        | Some x -> x
        in
        let new_decoded_rounds = match Map.find_opt current_session.current_round current_session.decoded_rounds with 
        | None -> Map.add current_session.current_round [{player=Tezos.sender; action=decoded_action}] current_session.decoded_rounds
        | Some (decodedPlayerActions) ->
            let _check_player_has_revealed_this_round = assert_with_error (Session.Utils.has_revealed(current_session, param.roundId, Tezos.sender) = false) "You already have revealed your play for this round" in
            Map.update current_session.current_round (Some({player=Tezos.sender; action=decoded_action} :: decodedPlayerActions)) current_session.decoded_rounds
        in
        let new_current_session : Session.Types.t = { current_session with asleep=Tezos.now + 600; decoded_rounds=new_decoded_rounds } in

        // compute board if all players have revealed
        let performed_actions : Session.Types.decoded_player_actions = match Map.find_opt new_current_session.current_round new_current_session.decoded_rounds with
        | None -> ([] : Session.Types.decoded_player_actions)
        | Some (pacts) -> pacts
        in
        let all_player_have_revealed((acc, pactions), elt : (bool * Session.Types.decoded_player_actions) * Session.Types.player) : (bool * Session.Types.decoded_player_actions) = (acc && Session.Utils.has_revealed_(pactions, elt), pactions) in
        let (check_all_players_have_revealed, _all_decoded_actions) : (bool * Session.Types.decoded_player_actions) = Set.fold all_player_have_revealed new_current_session.players (true, performed_actions) in
        // all players have given their actions, now the board can be updated and session goes to next round
        let modified_new_current_session : Session.Types.t = if (check_all_players_have_revealed = true) then 
            { new_current_session with current_round=new_current_session.current_round+1n; board=Session.Utils.update_board(new_current_session, new_current_session.current_round) }
            else
            new_current_session
        in
        // if session is finished, we can compute the result winner
        let final_current_session = if modified_new_current_session.current_round > modified_new_current_session.total_rounds then
                { modified_new_current_session with result=Session.Utils.compute_result(modified_new_current_session) }
            else
                modified_new_current_session
        in
        let new_storage : Types.t = { store with sessions=Map.update param.sessionId (Some(final_current_session)) store.sessions } in 
        (([]: operation list), new_storage)

end