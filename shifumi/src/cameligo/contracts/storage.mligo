#import "errors.mligo" "Errors"
#import "parameter.mligo" "Parameter"
#import "session.mligo" "Session"

type t = {
    next_session : nat;
    sessions : (nat, Session.t) map
}

[@inline]
let update_sessions (storage: t) (sessionId: nat) (new_session: Session.t): t =
    { storage with sessions=Map.update sessionId (Some(new_session)) storage.sessions}
