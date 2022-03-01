#import "storage.mligo" "Storage"
#import "parameter.mligo" "Parameter"
#import "views.mligo" "Views"
#import "errors.mligo" "Errors"
#import "session.mligo" "Session"
#import "conditions.mligo" "Conditions"

type storage = Storage.t
type parameter = Parameter.t
type return = operation list * storage

// Anyone can create a session (must specify players and number of rounds)
let createSession(param, store : Parameter.createsession_param * Storage.t) : operation list * Storage.t = 
    let new_session : Session.t = Session.new param.total_rounds param.players in
    let new_storage : Storage.t = { next_session=store.next_session + 1n; sessions=Map.add store.next_session new_session store.sessions} in
    (([]: operation list), new_storage)

// search for a non troller in the session
let find_me_a_name(sessionId, missing_players, current_session, store :nat * Session.player set * Session.t * Storage.t) : operation list * Storage.t = 
    let rem_player(acc, elt : address set * address ) : address set = Set.remove elt acc in
    let winners_set : address set = Set.fold rem_player missing_players current_session.players in
    let _check_has_winner : unit = assert_with_error (Set.size winners_set > 0n) Errors.no_winner in 
    let add_player(acc, elt : address list * address) : address list = elt :: acc in
    let winners_list : address list = Set.fold add_player winners_set ([] : address list) in
    let winner : address = Option.unopt (List.head_opt winners_list) in
    let new_current_session : Session.t = { current_session with result=Winner(winner) } in
    let new_storage : Storage.t = Storage.update_sessions store sessionId new_current_session in 
    (([]: operation list), new_storage )

// allow players to claim victory if opponent is a troller (refuse to play)
let stopSession(param, store : Parameter.stopsession_param * Storage.t) : operation list * Storage.t = 
    let current_session : Session.t = Storage.getSession(param.sessionId, store) in
    let _check_players : unit = Conditions.check_player_authorized Tezos.sender current_session.players Errors.user_not_allowed_to_stop_session in
    let _check_session_end : unit = Conditions.check_session_end current_session.result Inplay in
    let _check_asleep : unit = Conditions.check_asleep(current_session) in
    let current_round = match Map.find_opt current_session.current_round current_session.rounds with
    | None -> ([] : Session.player_actions)
    | Some rnd -> rnd 
    in
    let missing_players = Session.find_missing(current_round, current_session.players) in
    if Set.size missing_players > 0n then
        find_me_a_name (param.sessionId, missing_players, current_session, store)
    else
        let current_decoded_round = match Map.find_opt current_session.current_round current_session.decoded_rounds with
        | None -> (failwith("SHOULD NOT BE HERE SESSION IS BROKEN") : Session.decoded_player_actions)
        | Some rnd -> rnd 
        in
        let missing_players_for_reveal = Session.find_missing(current_decoded_round, current_session.players) in
        if Set.size missing_players_for_reveal > 0n then
            find_me_a_name (param.sessionId, missing_players_for_reveal, current_session, store)
        else
            (([]: operation list), store )


// the player create a chest with the chosen action (Stone | Paper | Cisor) in backend
// once the chest is created, the player send its chest to the smart contract
let play(param, store : Parameter.play_param * Storage.t) : operation list * Storage.t = 
    let current_session : Session.t = Storage.getSession(param.sessionId, store) in
    let _check_players : unit = Conditions.check_player_authorized Tezos.sender current_session.players Errors.user_not_allowed_to_play_in_session in
    let _check_session_end : unit = Conditions.check_session_end current_session.result Inplay in
    let _check_round : unit = assert_with_error (current_session.current_round = param.roundId) Errors.wrong_current_round in
    // register action
    let new_rounds = match Map.find_opt current_session.current_round current_session.rounds with 
    | None -> Map.add current_session.current_round [{player=Tezos.sender; action=param.action}] current_session.rounds
    | Some (playerActions) ->
        let _check_player_has_played_this_round = assert_with_error (Session.has_played_round current_session.rounds param.roundId Tezos.sender = false) Errors.user_already_played in
        Map.update current_session.current_round (Some({player=Tezos.sender; action=param.action} :: playerActions)) current_session.rounds
    in
    let new_session : Session.t = Session.update_rounds current_session new_rounds in
    let new_storage : Storage.t = Storage.update_sessions store param.sessionId new_session in 
    (([]: operation list), new_storage)

// Once all players have committed their chest, they must reveal the content of their chest
let reveal (param, store : Parameter.reveal_param * Storage.t) : operation list * Storage.t =
    // players can reveal only if all players have sent their chest
    let current_session : Session.t = Storage.getSession(param.sessionId, store) in
    let _check_players : unit = Conditions.check_player_authorized Tezos.sender current_session.players Errors.user_not_allowed_to_reveal_in_session in
    let _check_session_end : unit = Conditions.check_session_end current_session.result Inplay in
    let _check_round : unit = assert_with_error (current_session.current_round = param.roundId) Errors.wrong_current_round in
    let current_round_actions : Session.player_actions = match Map.find_opt current_session.current_round current_session.rounds with 
    | None -> failwith(Errors.missing_all_chests)
    | Some (round_actions) -> round_actions 
    in
    let numberOfPlayers : nat = Set.size current_session.players in
    let listsize (acc, _elt: nat * Session.player_action) : nat = acc + 1n in 
    let numberOfActions : nat = List.fold listsize current_round_actions 0n in 
    let _check_all_players_have_played : unit = assert_with_error (numberOfPlayers = numberOfActions) Errors.missing_player_chest in

    let rec find_chest(addr, lst_opt : address * Session.player_actions option) : chest option =
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
    | None -> (failwith(Errors.missing_sender_chest) : chest)
    | Some ch -> ch
    in
    // decode action
    let decoded_payload =
        match Tezos.open_chest param.player_key user_chest param.player_secret with
        | Ok_opening b -> b
        | Fail_timelock -> (failwith(Errors.failed_to_open_chest) : bytes)
        | Fail_decrypt -> (failwith(Errors.failed_to_open_chest) : bytes)
    in
    let decoded_action : Session.action = match (Bytes.unpack decoded_payload : Session.action option) with
    | None -> failwith(Errors.failed_to_unpack_payload)
    | Some x -> x
    in
    let new_decoded_rounds = match Map.find_opt current_session.current_round current_session.decoded_rounds with 
    | None -> Map.add current_session.current_round [{player=Tezos.sender; action=decoded_action}] current_session.decoded_rounds
    | Some (decodedPlayerActions) ->
        let _check_player_has_revealed_this_round = assert_with_error (Session.has_played_round current_session.decoded_rounds param.roundId Tezos.sender = false) Errors.user_already_revealed in
        Map.update current_session.current_round (Some({player=Tezos.sender; action=decoded_action} :: decodedPlayerActions)) current_session.decoded_rounds
    in
    let new_current_session : Session.t = { current_session with asleep=Tezos.now + 600; decoded_rounds=new_decoded_rounds } in

    // compute board if all players have revealed
    let performed_actions : Session.decoded_player_actions = match Map.find_opt new_current_session.current_round new_current_session.decoded_rounds with
    | None -> ([] : Session.decoded_player_actions)
    | Some (pacts) -> pacts
    in
    let all_player_have_revealed((acc, pactions), elt : (bool * Session.decoded_player_actions) * Session.player) : (bool * Session.decoded_player_actions) = (acc && Session.has_played pactions elt, pactions) in
    let (check_all_players_have_revealed, _all_decoded_actions) : (bool * Session.decoded_player_actions) = Set.fold all_player_have_revealed new_current_session.players (true, performed_actions) in
    // all players have given their actions, now the board can be updated and session goes to next round
    let modified_new_current_session : Session.t = if (check_all_players_have_revealed = true) then 
        { new_current_session with current_round=new_current_session.current_round+1n; board=Session.update_board(new_current_session, new_current_session.current_round) }
        else
        new_current_session
    in
    // if session is finished, we can compute the result winner
    let final_current_session = if modified_new_current_session.current_round > modified_new_current_session.total_rounds then
            { modified_new_current_session with result=Session.compute_result(modified_new_current_session) }
        else
            modified_new_current_session
    in
    let new_storage : Storage.t = { store with sessions=Map.update param.sessionId (Some(final_current_session)) store.sessions } in 
    (([]: operation list), new_storage)


let main(ep, store : parameter * storage) : return =
    match ep with 
    | CreateSession(p) -> createSession(p, store)
    | Play(p) -> play(p, store)
    | RevealPlay (r) -> reveal(r, store)
    | StopSession (c) -> stopSession(c, store)


[@view] let board(sessionId, store: nat * storage): Views.sessionBoard = 
    match Map.find_opt sessionId store.sessions with
    | Some (sess) -> Views.retrieve_board(sess)
    | None -> (failwith("Unknown session") : Views.sessionBoard)
