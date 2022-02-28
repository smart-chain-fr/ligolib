
module Types = struct

    type player = address
    type round = nat
    type action = Stone | Paper | Cisor
    type result = Inplay | Draw | Winner of address

    type player_action = {
        player : player;
        action : chest 
    }

    type decoded_player_action = {
        player : player;
        action : action 
    }

    type player_actions = player_action list
    type decoded_player_actions = decoded_player_action list

    type board = (round, player option) map

    type t = {
        total_rounds : nat;
        players : player set;
        current_round : nat;
        rounds : (round, player_actions) map;
        decoded_rounds : (round, decoded_player_actions) map;
        board : board;
        result : result;
        asleep : timestamp
    }

end

module Utils = struct

    let find_missing_players(pactions, all_players : Types.player_actions * Types.player set) : Types.player set =
        let discard_player(acc, elt : address set * Types.player_action) : address set = Set.remove elt.player acc in
        List.fold discard_player pactions all_players 

    let find_missing_players_for_reveal(pactions, all_players : Types.decoded_player_actions * Types.player set) : Types.player set =
        let discard_player(acc, elt : address set * Types.decoded_player_action) : address set = Set.remove elt.player acc in
        List.fold discard_player pactions all_players 

    [@inline]
    let has_played_(pactions, player : Types.player_actions * Types.player) : bool =
        let check_contains(acc, elt : bool * Types.player_action) : bool = if acc then acc else (elt.player = player) in
        List.fold check_contains pactions false 

    [@inline]
    let has_played(sess, roundId, player : Types.t * nat * Types.player) : bool =
        match Map.find_opt roundId sess.rounds with
        | Some (acts) -> has_played_(acts, player)
        | None -> false 

    [@inline]
    let has_revealed_(pactions, player : Types.decoded_player_actions * Types.player) : bool =
        let check_contains(acc, elt : bool * Types.decoded_player_action) : bool = if acc then acc else (elt.player = player) in
        List.fold check_contains pactions false 
    
    [@inline]
    let has_revealed(sess, roundId, player : Types.t * nat * Types.player) : bool =
        match Map.find_opt roundId sess.decoded_rounds with
        | Some (acts) -> has_revealed_(acts, player)
        | None -> false 

    [@inline]
    let resolve(first, second : Types.decoded_player_action * Types.decoded_player_action) : Types.player option = 
        let result : Types.player option = match first.action, second.action with
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
    let update_board(sess, current_round: Types.t * Types.round) : Types.board =
    //let resolve_board(sess: session) : board = 
        // process actions for current_round
        let pactions : Types.decoded_player_actions = match Map.find_opt current_round sess.decoded_rounds with
        | None -> (failwith("Missing actions for current_round") : Types.decoded_player_actions)
        | Some (pacts) -> pacts
        in
        let first : Types.decoded_player_action = match List.head_opt(pactions) with
        | None -> (failwith("Missing actions for first player") : Types.decoded_player_action)
        | Some (act) -> act
        in
        let next_players_opt : Types.decoded_player_action list option = List.tail_opt pactions in
        let next_players : Types.decoded_player_action list = match next_players_opt with
        | None -> (failwith("Missing actions for second player") : Types.decoded_player_action list)
        | Some (tl) -> tl
        in
        let second : Types.decoded_player_action = match List.head_opt(next_players) with
        | None -> (failwith("Missing actions for second player") : Types.decoded_player_action)
        | Some (act) -> act
        in
        let result : Types.player option = resolve(first, second) in 
        match result with 
        | None -> Map.update current_round (None : Types.player option option) sess.board
        | Some (r) -> Map.update current_round (Some(Some(r))) sess.board

    let compute_result(sess: Types.t) : Types.result =
        // parse board and compute who won
        //let scores : (address, nat) map = (Map.empty : (address, nat) map) in
        let compute_points(acc, elt : (address, nat) map * (Types.round * Types.player option)) : (address, nat) map = match elt.1 with
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

end