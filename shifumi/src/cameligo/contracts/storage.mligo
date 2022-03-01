#import "errors.mligo" "Errors"
#import "parameter.mligo" "Parameter"
#import "session.mligo" "Session"
#import "conditions.mligo" "Conditions"

type t = {
    next_session : nat;
    sessions : (nat, Session.t) map
}

[@inline]
let update_sessions (storage: t) (sessionId: nat) (new_session: Session.t): t =
    { storage with sessions=Map.update sessionId (Some(new_session)) storage.sessions}

[@inline]
let getSession (sessionId, store : nat * t) : Session.t =
    match Map.find_opt sessionId store.sessions with
    | None -> (failwith(Errors.unknown_session) : Session.t)
    | Some (sess) -> sess
