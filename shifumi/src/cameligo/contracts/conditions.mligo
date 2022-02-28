#import "errors.mligo" "Errors"
#import "session.mligo" "Session"

[@inline]
let check_player_authorized (current_session, error_message : Session.Types.t * string) : unit =
    assert_with_error (Set.mem Tezos.sender current_session.players) error_message

[@inline]
let check_session_end(current_session : Session.Types.t) : unit =
    assert_with_error (current_session.result = (Inplay : Session.Types.result)) Errors.session_finished

[@inline]
let check_asleep (current_session : Session.Types.t) : unit = 
    assert_with_error (Tezos.now > current_session.asleep) Errors.must_wait_10_min
