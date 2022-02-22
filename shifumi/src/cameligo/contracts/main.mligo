#import "storage.mligo" "Storage"
#import "parameter.mligo" "Parameter"


type storage = Storage.Types.t
type parameter = Parameter.Types.t
type return = operation list * storage

//type sessionBoard = {
//    points : (address, nat) map
//}

//let retrieve_board(sess : Storage.Session.Types.t) : sessionBoard =
//    let scores : (address, nat) map = (Map.empty : (address, nat) map) in
//    let myfunc(acc, elt : (address, nat) map * (round * address option)) : (address, nat) map = match elt.1 with
//    | None -> acc
//    | Some winner_round -> (match Map.find_opt winner_round acc with
//        | None -> Map.add winner_round 1n acc
//        | Some old_value -> Map.update winner_round (Some(old_value + 1n)) acc)
//    in
//    let final_scores = Map.fold myfunc sess.board scores in
//    { points=final_scores }

let main(ep, store : parameter * storage) : return =
    match ep with 
    | CreateSession(p) -> Storage.Utils.createSession(p, store)
    | Play(p) -> Storage.Utils.play(p, store)
    | RevealPlay (r) -> Storage.Utils.reveal(r, store)
    | StopSession (c) -> Storage.Utils.stopSession(c, store)


//[@view] let board(sessionId, store: nat * storage): sessionBoard = 
//    match Map.find_opt sessionId store.sessions with
//    | Some (sess) -> retrieve_board(sess)
//    | None -> (failwith("Unknown session") : sessionBoard)
