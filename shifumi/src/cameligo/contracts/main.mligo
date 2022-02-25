#import "storage.mligo" "Storage"
#import "parameter.mligo" "Parameter"
#import "views.mligo" "Views"
#import "errors.mligo" "Errors"

type storage = Storage.Types.t
type parameter = Parameter.Types.t
type return = operation list * storage

let main(ep, store : parameter * storage) : return =
    match ep with 
    | CreateSession(p) -> Storage.Utils.createSession(p, store)
    | Play(p) -> Storage.Utils.play(p, store)
    | RevealPlay (r) -> Storage.Utils.reveal(r, store)
    | StopSession (c) -> Storage.Utils.stopSession(c, store)


[@view] let board(sessionId, store: nat * storage): Views.Types.sessionBoard = 
    match Map.find_opt sessionId store.sessions with
    | Some (sess) -> Views.Utils.retrieve_board(sess)
    | None -> (failwith("Unknown session") : Views.Types.sessionBoard)
