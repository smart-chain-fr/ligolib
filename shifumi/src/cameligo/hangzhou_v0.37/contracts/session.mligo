#import "errors.mligo" "Errors"

type player = address
type round = nat
type action = Stone | Paper | Cisor
type result = Inplay | Draw | Winner of address

type 'a an_action = {
    player : player;
    action : 'a 
}

type player_action = chest an_action
type decoded_player_action = action an_action

type player_actions = player_action list
type decoded_player_actions = decoded_player_action list

type 'a rounds = (round, 'a an_action list) map 

type board = (round, player option) map

type t = {
    total_rounds : nat;
    players : player set;
    current_round : nat;
    rounds : chest rounds;
    decoded_rounds : action rounds;
    board : board;
    result : result;
    asleep : timestamp
}


[@inline]
let new (total_rounds: nat) (players: player set): t =
    { 
      asleep=Tezos.now + 600; 
      total_rounds=total_rounds; 
      players=players; 
      current_round=1n; 
      rounds=(Map.empty : chest rounds);
      decoded_rounds=(Map.empty : action rounds); 
      board=(Map.empty : board); 
      result=Inplay 
    }  

[@inline]
let get_round_actions (roundId : nat) (session : t) : player_actions =
    match Map.find_opt roundId session.rounds with 
    | None -> failwith(Errors.missing_all_chests)
    | Some (round_actions) -> round_actions 

[@inline]
let get_decoded_round_actions (roundId : nat) (session : t) : decoded_player_actions =
    match Map.find_opt roundId session.decoded_rounds with 
    | None -> failwith(Errors.missing_all_decoded_chests)
    | Some (decoded_round_actions) -> decoded_round_actions 

[@inline]
let update_rounds (session: t) (rounds: (round, player_actions) map): t =
    { session with asleep=Tezos.now + 600; rounds=rounds }    

[@inline]
let update_decoded_rounds (session: t) (decoded_rounds: (round, decoded_player_actions) map): t =
    { session with asleep=Tezos.now + 600; decoded_rounds=decoded_rounds }    

[@inline]
let find_missing (type a) (pactions, all_players : a an_action list * player set) =
    let discard_player(acc, elt : address set * a an_action) : address set = Set.remove elt.player acc in
    List.fold discard_player pactions all_players 

[@inline]
let has_played (type a) (pactions: a an_action list) (player : player) : bool =
    let check_contains(acc, elt : bool * a an_action) : bool = if acc then acc else (elt.player = player) in
    List.fold check_contains pactions false 

[@inline]
let has_played_round (type a) (rounds: a rounds) (roundId: round) (player: player) : bool =
    match Map.find_opt roundId rounds with
    | Some (acts) -> has_played acts player
    | None -> false 

[@inline]
let add_in_decoded_rounds (roundId : nat) (session : t) (user : address) (decoded_action: action) : action rounds =
    match Map.find_opt roundId session.decoded_rounds with 
    | None -> Map.add roundId [{player=user; action=decoded_action}] session.decoded_rounds
    | Some (decodedPlayerActions) ->
        let _check_player_has_revealed_this_round = assert_with_error (has_played_round session.decoded_rounds roundId user = false) Errors.user_already_revealed in
        Map.update roundId (Some({player=user; action=decoded_action} :: decodedPlayerActions)) session.decoded_rounds

[@inline]
let add_in_rounds (roundId : nat) (session : t) (user : address) (action: chest) : chest rounds =
    match Map.find_opt roundId session.rounds with 
    | None -> Map.add roundId [{player=user; action=action}] session.rounds
    | Some (playerActions) ->
        let _check_player_has_played_this_round = assert_with_error (has_played_round session.rounds roundId user = false) Errors.user_already_played in
        Map.update roundId (Some({player=user; action=action} :: playerActions)) session.rounds

[@inline]
let get_chest_exn (user : address) (actions_opt : player_actions option) : chest =
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
    match find_chest(user, actions_opt) with
    | None -> (failwith(Errors.missing_sender_chest) : chest)
    | Some ch -> ch

[@inline]
let decode_chest_exn (player_key: chest_key) (user_chest: chest) (player_secret: nat): action = 
    let decoded_payload =
        match Tezos.open_chest player_key user_chest player_secret with
        | Ok_opening b -> b
        | Fail_timelock -> (failwith(Errors.failed_to_open_chest) : bytes)
        | Fail_decrypt -> (failwith(Errors.failed_to_open_chest) : bytes)
    in
    match (Bytes.unpack decoded_payload : action option) with
    | None -> failwith(Errors.failed_to_unpack_payload)
    | Some x -> x
    

[@inline]
let resolve(first, second : decoded_player_action * decoded_player_action) : player option = 
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
let update_board(sess, current_round: t * round) : board =
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


[@inline]
let finalize_current_round (session: t) : t =
    // retrieve decoded_player_actions of given roundId
    let performed_actions : decoded_player_actions = match Map.find_opt session.current_round session.decoded_rounds with
    | None -> ([] : decoded_player_actions)
    | Some (pacts) -> pacts
    in
    // verify all players have revealed
    let all_player_have_revealed((acc, pactions), elt : (bool * decoded_player_actions) * player) : (bool * decoded_player_actions) = (acc && has_played pactions elt, pactions) in
    let (check_all_players_have_revealed, _all_decoded_actions) : (bool * decoded_player_actions) = Set.fold all_player_have_revealed session.players (true, performed_actions) in
    // all players have given their actions, now the board can be updated and session goes to next round
    if (check_all_players_have_revealed = true) then 
        { session with current_round=session.current_round+1n; board=update_board(session, session.current_round) }
    else
        session

        
let compute_result(sess: t) : result =
    // parse board and compute who won
    let compute_points(acc, elt : (address, nat) map * (round * player option)) : (address, nat) map = match elt.1 with
    | None -> acc
    | Some winner_round -> (match Map.find_opt winner_round acc with
        | None -> Map.add winner_round 1n acc
        | Some old_value -> Map.update winner_round (Some(old_value + 1n)) acc)
    in
    let final_scores = Map.fold compute_points sess.board (Map.empty : (address, nat) map) in
    let (winner_addr, winner_points, multiple_winners) : (address option * nat * bool) = ((None : address option), 0n, false) in
    let leader_score((win_addr, win_points, multiple), elt : (address option * nat * bool) * (address * nat)) : (address option * nat * bool) =
        match win_addr with
        | None -> (Some(elt.0), elt.1, false)
        | Some _temp_win_addr -> 
            if elt.1 > win_points then 
                (Some(elt.0), elt.1, false)
            else
                if elt.1 = win_points then
                    (win_addr, win_points, true)
                else
                    (win_addr, win_points, multiple)
    in 
    let (final_winner_addr, _final_winner_points, final_multiple) = Map.fold leader_score final_scores (winner_addr, winner_points, multiple_winners) in
    if final_multiple then
        Draw
    else
        match final_winner_addr with
        | None -> Draw
        | Some x -> Winner(x)



[@inline]
let finalize_session (session: t) : t =
    if session.current_round > session.total_rounds then
        { session with result=compute_result(session) }
    else
        session
