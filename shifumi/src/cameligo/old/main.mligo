
type player = address
type round = nat
type action = Stone | Paper | Cisor
type result = Inplay | Draw | Winner of address

type player_action = {
    player : player;
    action : chest     // should be a chest (in order to offuscate the action performed by other players)
}

type decoded_player_action = {
    player : player;
    action : action 
}

type player_actions = player_action list
type decoded_player_actions = decoded_player_action list

type board = (round, player option) map

type session = {
    total_rounds : nat;
    players : player set;
    current_round : nat;
    rounds : (round, player_actions) map;
    decoded_rounds : (round, decoded_player_actions) map;
    board : board;
    result : result;
    asleep : timestamp
}

let find_missing_players(pactions, all_players : player_actions * player set) : player set =
    let discard_player(acc, elt : address set * player_action) : address set = Set.remove elt.player acc in
    List.fold discard_player pactions all_players 

let find_missing_players_for_reveal(pactions, all_players : decoded_player_actions * player set) : player set =
    let discard_player(acc, elt : address set * decoded_player_action) : address set = Set.remove elt.player acc in
    List.fold discard_player pactions all_players 



let has_played(sess, roundId, player : session * nat * player) : bool =
    match Map.find_opt roundId sess.rounds with
    | Some (acts) -> 
        let check_contains(acc, elt : bool * player_action) : bool = if acc then acc else (elt.player = player) in
        List.fold check_contains acts false 
    | None -> false 

let has_played_(pactions, player : player_actions * player) : bool =
    let check_contains(acc, elt : bool * player_action) : bool = if acc then acc else (elt.player = player) in
    List.fold check_contains pactions false 

let has_revealed(sess, roundId, player : session * nat * player) : bool =
    match Map.find_opt roundId sess.decoded_rounds with
    | Some (acts) -> 
        let check_contains(acc, elt : bool * decoded_player_action) : bool = if acc then acc else (elt.player = player) in
        List.fold check_contains acts false 
    | None -> false 

let has_revealed_(pactions, player : decoded_player_actions * player) : bool =
    let check_contains(acc, elt : bool * decoded_player_action) : bool = if acc then acc else (elt.player = player) in
    List.fold check_contains pactions false 

let resolve(first, second : decoded_player_action * decoded_player_action) : player option = 
    //let first_action : action = first.action in
    //let second_action : action = second.action in 
    let result : player option = match first.action, second.action with
    | Stone, Stone -> None
    | Stone, Paper -> Some(second.player)
    | Stone, Cisor -> Some(first.player)
    | Paper, Stone -> Some(first.player)
    | Paper, Paper -> None
    | Paper, Cisor -> Some(second.player)
    | Cisor, Stone -> Some(second.player)
    | Cisor, Paper -> Some(first.player)
    | Cisor, Cisor -> None
    in
    result

// TODO , this implementation can handle only 2 players :(
let update_board(sess, current_round: session * round) : board =
//let resolve_board(sess: session) : board = 
    // process actions for current_round
    let pactions : decoded_player_actions = match Map.find_opt current_round sess.decoded_rounds with
    | None -> (failwith("Missing actions for current_round") : decoded_player_actions)
    | Some (pacts) -> pacts
    in
    let first : decoded_player_action = match List.head_opt(pactions) with
    | None -> (failwith("Missing actions for first player") : decoded_player_action)
    | Some (act) -> act
    in
    let next_players_opt : decoded_player_action list option = List.tail_opt pactions in
    let next_players : decoded_player_action list = match next_players_opt with
    | None -> (failwith("Missing actions for second player") : decoded_player_action list)
    | Some (tl) -> tl
    in
    let second : decoded_player_action = match List.head_opt(next_players) with
    | None -> (failwith("Missing actions for second player") : decoded_player_action)
    | Some (act) -> act
    in
    let result : player option = resolve(first, second) in 
    match result with 
    | None -> Map.update current_round (None : player option option) sess.board
    | Some (r) -> Map.update current_round (Some(Some(r))) sess.board

let compute_result(sess: session) : result =
    // parse board and compute who won
    let scores : (address, nat) map = (Map.empty : (address, nat) map) in
    let myfunc(acc, elt : (address, nat) map * (round * player option)) : (address, nat) map = match elt.1 with
    | None -> acc
    | Some winner_round -> (match Map.find_opt winner_round acc with
        | None -> Map.add winner_round 1n acc
        | Some old_value -> Map.update winner_round (Some(old_value + 1n)) acc)
    in
    let final_scores = Map.fold myfunc sess.board scores in
    let (winner_addr, winner_points, multiple_winners) : (address option * nat * bool) = ((None : address option), 0n, false) in
    let leader_score((win_addr, win_points, multiple), elt : (address option * nat * bool) * (address * nat)) : (address option * nat * bool) =
        match win_addr with
        | None -> (Some(elt.0), elt.1, false)
        | Some temp_win_addr -> 
            if elt.1 > win_points then 
                (Some(elt.0), elt.1, false)
            else
                if elt.1 = win_points then
                    (win_addr, win_points, true)
                else
                    (win_addr, win_points, multiple)
    in 
    let (final_winner_addr, final_winner_points, final_multiple) = Map.fold leader_score final_scores (winner_addr, winner_points, multiple_winners) in
    if final_multiple then
        Draw
    else
        match final_winner_addr with
        | None -> Draw
        | Some x -> Winner(x)


type sessionBoard = {
    points : (player, nat) map
}

type shifumiStorage = {
    next_session : nat;
    sessions : (nat, session) map
}

type createsession_param = {
    total_rounds : nat;
    players : player set;
}

type stopsession_param = {
    sessionId : nat;
}

type play_param = {
    sessionId : nat;
    roundId : nat;
    action : chest
}

type reveal_param = {
    sessionId : nat;
    roundId : nat;
    player_key : chest_key;
    player_secret : nat
}

type shifumiEntrypoints = CreateSession of createsession_param | Play of play_param | RevealPlay of reveal_param | StopSession of stopsession_param

type shifumiFullReturn = operation list * shifumiStorage

let createSession(param, store : createsession_param * shifumiStorage) : shifumiFullReturn = 
    let new_session : session = { asleep=Tezos.now + 600; total_rounds=param.total_rounds; players=param.players; current_round=1n; rounds=(Map.empty : (round, player_actions) map); decoded_rounds=(Map.empty : (round, decoded_player_actions) map); board=(Map.empty : board); result=Inplay } in
    let new_storage : shifumiStorage = { next_session=store.next_session + 1n; sessions=Map.add store.next_session new_session store.sessions} in
    (([]: operation list), new_storage)

let stopSession(param, store : stopsession_param * shifumiStorage) : shifumiFullReturn = 
    let current_session : session = match Map.find_opt param.sessionId store.sessions with
    | None -> (failwith("Unknown session") : session)
    | Some (sess) -> sess
    in
    let _check_asleep : unit = assert_with_error (Tezos.now > current_session.asleep) "Must wait at least 600 seconds before claiming Victory (in case opponent is not playing)" in
    let _check_players : unit = assert_with_error (Set.mem Tezos.sender current_session.players) "Not allowed to stop this session" in
    let _check_session_end : unit = assert_with_error (current_session.result = (Inplay : result)) "this session is finished" in
    let current_round = match Map.find_opt current_session.current_round current_session.rounds with
    | None -> (failwith("SHOULD NOT BE HERE SESSION IS BROKEN") : player_actions)
    | Some rnd -> rnd 
    in
    let missing_players = find_missing_players(current_round, current_session.players) in
    if Set.size missing_players > 0n then
        let rem_player(acc, elt : address set * address ) : address set = Set.remove elt acc in
        let winners_set : address set = Set.fold rem_player missing_players current_session.players in
        let add_player(acc, elt : address list * address) : address list = elt :: acc in
        let winners_list : address list = Set.fold add_player winners_set ([] : address list) in
        let winner : address = Option.unopt (List.head_opt winners_list) in
        let new_current_session : session = { current_session with result=Winner(winner) } in
        let new_storage : shifumiStorage = { store with sessions=Map.update param.sessionId (Some(new_current_session)) store.sessions} in 
        (([]: operation list), new_storage )
    else
        let current_decoded_round = match Map.find_opt current_session.current_round current_session.decoded_rounds with
        | None -> (failwith("SHOULD NOT BE HERE SESSION IS BROKEN") : decoded_player_actions)
        | Some rnd -> rnd 
        in
        let missing_players_for_reveal = find_missing_players_for_reveal(current_decoded_round, current_session.players) in
        if Set.size missing_players_for_reveal > 0n then
            let rem_player(acc, elt : address set * address ) : address set = Set.remove elt acc in
            let winners_set : address set = Set.fold rem_player missing_players_for_reveal current_session.players in
            let add_player(acc, elt : address list * address) : address list = elt :: acc in
            let winners_list : address list = Set.fold add_player winners_set ([] : address list) in
            let winner : address = Option.unopt (List.head_opt winners_list) in
            let new_current_session : session = { current_session with result=Winner(winner) } in
            let new_storage : shifumiStorage = { store with sessions=Map.update param.sessionId (Some(new_current_session)) store.sessions} in 
            (([]: operation list), new_storage )
        else
            (([]: operation list), store )


// the player create a chest with the chosen action (Stone | Paper | Cisor) in backend
// once the chest is created, the player send its chest to the smart contract
let play(param, store : play_param * shifumiStorage) : shifumiFullReturn = 
    let current_session : session = match Map.find_opt param.sessionId store.sessions with
    | None -> (failwith("Unknown session") : session)
    | Some (sess) -> sess
    in
    let _check_players : unit = assert_with_error (Set.mem Tezos.sender current_session.players) "Not allowed to play in this session" in
    let _check_round : unit = assert_with_error (current_session.current_round = param.roundId) "Wrong round parameter" in
    // register action
    let new_rounds = match Map.find_opt current_session.current_round current_session.rounds with 
    | None -> Map.add current_session.current_round [{player=Tezos.sender; action=param.action}] current_session.rounds
    | Some (playerActions) ->
        let _check_player_has_played_this_round = assert_with_error (has_played(current_session, param.roundId, Tezos.sender) = false) "You already have played for this round" in
        Map.update current_session.current_round (Some({player=Tezos.sender; action=param.action} :: playerActions)) current_session.rounds
    in
    let new_current_session : session = { current_session with asleep=Tezos.now + 600; rounds=new_rounds } in
    let new_storage : shifumiStorage = { store with sessions=Map.update param.sessionId (Some(new_current_session)) store.sessions} in 
    (([]: operation list), new_storage)

let reveal (param, store : reveal_param * shifumiStorage) : shifumiFullReturn =
    // players can reveal only if all players have sent their chest
    let current_session : session = match Map.find_opt param.sessionId store.sessions with
    | None -> (failwith("Unknown session") : session)
    | Some (sess) -> sess
    in
    let _check_players : unit = assert_with_error (Set.mem Tezos.sender current_session.players) "Not allowed to play in this session" in
    let _check_round : unit = assert_with_error (current_session.current_round = param.roundId) "Wrong round parameter" in
    let current_round_actions : player_actions = match Map.find_opt current_session.current_round current_session.rounds with 
    | None -> failwith("no actions registered")
    | Some (round_actions) -> round_actions 
    in
    let numberOfPlayers : nat = Set.size current_session.players in
    let listsize (acc, _elt: nat * player_action) : nat = acc + 1n in 
    let numberOfActions : nat = List.fold listsize current_round_actions 0n in 
    let _check_all_players_have_played : unit = assert_with_error (numberOfPlayers = numberOfActions) "a player has not played" in

    let rec find_chest(addr, lst_opt : address * player_actions option) : chest option =
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
    let decoded_action : action = match (Bytes.unpack decoded_payload : action option) with
    | None -> failwith("Failed to unpack the payload")
    | Some x -> x
    in
    let new_decoded_rounds = match Map.find_opt current_session.current_round current_session.decoded_rounds with 
    | None -> Map.add current_session.current_round [{player=Tezos.sender; action=decoded_action}] current_session.decoded_rounds
    | Some (decodedPlayerActions) ->
        let _check_player_has_revealed_this_round = assert_with_error (has_revealed(current_session, param.roundId, Tezos.sender) = false) "You already have revealed your play for this round" in
        Map.update current_session.current_round (Some({player=Tezos.sender; action=decoded_action} :: decodedPlayerActions)) current_session.decoded_rounds
    in
    let new_current_session : session = { current_session with asleep=Tezos.now + 600; decoded_rounds=new_decoded_rounds } in

    // compute board if all players have revealed
    let performed_actions : decoded_player_actions = match Map.find_opt new_current_session.current_round new_current_session.decoded_rounds with
    | None -> ([] : decoded_player_actions)
    | Some (pacts) -> pacts
    in
    let all_player_have_revealed((acc, pactions), elt : (bool * decoded_player_actions) * player) : (bool * decoded_player_actions) = (acc && has_revealed_(pactions, elt), pactions) in
    let (check_all_players_have_revealed, _all_decoded_actions) : (bool * decoded_player_actions) = Set.fold all_player_have_revealed new_current_session.players (true, performed_actions) in
    // all players have given their actions, now the board can be updated and session goes to next round
    let modified_new_current_session : session = if (check_all_players_have_revealed = true) then 
        { new_current_session with current_round=new_current_session.current_round+1n; board=update_board(new_current_session, new_current_session.current_round) }
        else
        new_current_session
    in
    // if session is finished, we can compute the result winner
    let final_current_session = if modified_new_current_session.current_round > modified_new_current_session.total_rounds then
            { modified_new_current_session with result=compute_result(modified_new_current_session) }
        else
            modified_new_current_session
    in
    let new_storage : shifumiStorage = { store with sessions=Map.update param.sessionId (Some(final_current_session)) store.sessions } in 
    (([]: operation list), new_storage)

// TODO computes points
let retrieve_board(sess : session) : sessionBoard =
    let scores : (address, nat) map = (Map.empty : (address, nat) map) in
    let myfunc(acc, elt : (address, nat) map * (round * player option)) : (address, nat) map = match elt.1 with
    | None -> acc
    | Some winner_round -> (match Map.find_opt winner_round acc with
        | None -> Map.add winner_round 1n acc
        | Some old_value -> Map.update winner_round (Some(old_value + 1n)) acc)
    in
    let final_scores = Map.fold myfunc sess.board scores in
    { points=final_scores }

let shifumiMain(ep, store : shifumiEntrypoints * shifumiStorage) : shifumiFullReturn =
    match ep with 
    | CreateSession(p) -> createSession(p, store)
    | Play(p) -> play(p, store)
    | RevealPlay (r) -> reveal(r, store)
    | StopSession (c) -> stopSession(c, store)

[@view] let board(sessionId, store: nat * shifumiStorage): sessionBoard = 
    match Map.find_opt sessionId store.sessions with
    | Some (sess) -> retrieve_board(sess)
    | None -> (failwith("Unknown session") : sessionBoard)

