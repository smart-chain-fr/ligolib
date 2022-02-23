#import "session.mligo" "Session"

module Types = struct
    type sessionBoard = {
        points : (address, nat) map
    }

end

module Utils = struct

let retrieve_board(sess : Session.Types.t) : Types.sessionBoard =
    let scores : (address, nat) map = (Map.empty : (address, nat) map) in
    let myfunc(acc, elt : (address, nat) map * (Session.Types.round * address option)) : (address, nat) map = match elt.1 with
    | None -> acc
    | Some winner_round -> (match Map.find_opt winner_round acc with
        | None -> Map.add winner_round 1n acc
        | Some old_value -> Map.update winner_round (Some(old_value + 1n)) acc)
    in
    let final_scores = Map.fold myfunc sess.board scores in
    { points=final_scores }

end
