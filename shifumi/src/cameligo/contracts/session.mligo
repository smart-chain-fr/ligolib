
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

type board = (round, player option) map

type 'a rounds = (round, 'a an_action list) map 

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
let update_rounds (session: t) (rounds: (round, player_actions) map): t =
    { session with asleep=Tezos.now + 600; rounds=rounds }    

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

//
// REMARK: this is a game domain specific behavior / Not linked to the storage
//
let resolve(first, second : decoded_player_action * decoded_player_action) : player option = 
    match first.action, second.action with
    | Stone , Stone -> None
    | Stone , Paper -> Some(second.player)
    | Stone , Cisor -> Some(first.player)
    | Paper , Stone -> Some(first.player)
    | Paper , Paper -> None
    | Paper , Cisor -> Some(second.player)
    | Cisor , Stone -> Some(second.player)
    | Cisor , Paper -> Some(first.player)
    | Cisor , Cisor -> None

// TODO , this implementation can handle only 2 players :(
let update_board(sess, current_round: t * round) : board =
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

let compute_result(sess: t) : result =
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
