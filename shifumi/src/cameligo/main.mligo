
type player = address
type round = nat
type action = Stone | Paper | Cisor

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
}

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
let resolve_board(sess: session) : board = 
    // process actions for current_round
    let pactions : decoded_player_actions = match Map.find_opt sess.current_round sess.decoded_rounds with
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
    | None -> Map.update sess.current_round (None : player option option) sess.board
    | Some (r) -> Map.update sess.current_round (Some(Some(r))) sess.board


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

type play_param = {
    sessionId : nat;
    roundId : nat;
    action : chest
}

type reveal_param = {
    sessionId : nat;
    roundId : nat;
    player_chest : chest;
    player_key : chest_key;
    player_secret : nat
}

type shifumiEntrypoints = CreateSession of createsession_param | Play of play_param | RevealPlay of reveal_param

type shifumiFullReturn = operation list * shifumiStorage

let createSession(param, store : createsession_param * shifumiStorage) : shifumiFullReturn = 
    let new_session : session = { total_rounds=param.total_rounds; players=param.players; current_round=1n; rounds=(Map.empty : (round, player_actions) map); decoded_rounds=(Map.empty : (round, decoded_player_actions) map); board=(Map.empty : board) } in
    let new_storage : shifumiStorage = { next_session=store.next_session + 1n; sessions=Map.add store.next_session new_session store.sessions} in
    (([]: operation list), new_storage)

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
    let new_current_session : session = { current_session with rounds=new_rounds } in
    let new_storage : shifumiStorage = { store with sessions=Map.update param.sessionId (Some(new_current_session)) store.sessions} in 
    
    // compute board if all players have played
    //let performed_actions : player_actions = match Map.find_opt current_session.current_round current_session.rounds with
    //| None -> ([] : player_actions)
    //| Some (pacts) -> pacts
    //in
    //let all_player_have_played((acc, pactions), elt : (bool * player_actions) * player) : (bool * player_actions) = (acc && has_played_(pactions, elt), pactions) in
    //let (check_all_players_have_played, _all_actions) : (bool * player_actions) = Set.fold all_player_have_played new_current_session.players (true, performed_actions) in
    //// all players have given their actions, now the board can be resolved and goes to next round
    //let modified_new_current_session : session = if (check_all_players_have_played = true) then 
    //    { new_current_session with current_round=new_current_session.current_round+1n; board=resolve_board(new_current_session) }
    //    else
    //    new_current_session
    //in
    //let new_storage : shifumiStorage = { store with sessions=Map.update param.sessionId (Some(modified_new_current_session)) store.sessions } in 
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
    // decode action
    let decoded_payload =
        match Tezos.open_chest param.player_key param.player_chest param.player_secret with
        | Ok_opening b -> b
        | Fail_timelock -> 0x00
        | Fail_decrypt -> 0x01
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
    let new_current_session : session = { current_session with decoded_rounds=new_decoded_rounds } in

    // compute board if all players have revealed
    let performed_actions : decoded_player_actions = match Map.find_opt current_session.current_round current_session.decoded_rounds with
    | None -> ([] : decoded_player_actions)
    | Some (pacts) -> pacts
    in
    let all_player_have_revealed((acc, pactions), elt : (bool * decoded_player_actions) * player) : (bool * decoded_player_actions) = (acc && has_revealed_(pactions, elt), pactions) in
    let (check_all_players_have_revealed, _all_decoded_actions) : (bool * decoded_player_actions) = Set.fold all_player_have_revealed new_current_session.players (true, performed_actions) in
    // all players have given their actions, now the board can be resolved and goes to next round
    let modified_new_current_session : session = if (check_all_players_have_revealed = true) then 
        { new_current_session with current_round=new_current_session.current_round+1n; board=resolve_board(new_current_session) }
        else
        new_current_session
    in
    let new_storage : shifumiStorage = { store with sessions=Map.update param.sessionId (Some(modified_new_current_session)) store.sessions } in 
    (([]: operation list), new_storage)

// TODO computes points
let retrieve_board(_sess : session) : sessionBoard =
    { points=(Map.empty : (player, nat) map) }

let shifumiMain(ep, store : shifumiEntrypoints * shifumiStorage) : shifumiFullReturn =
    match ep with 
    | CreateSession(p) -> createSession(p, store)
    | Play(p) -> play(p, store)
    | RevealPlay (r) -> reveal(r, store)

[@view] let board(sessionId, store: nat * shifumiStorage): sessionBoard = 
    match Map.find_opt sessionId store.sessions with
    | Some (sess) -> retrieve_board(sess)
    | None -> (failwith("Unknown session") : sessionBoard)

