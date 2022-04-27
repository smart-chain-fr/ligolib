#import "errors.mligo" "Errors"
#import "session.mligo" "Session"

[@inline]
let check_player_authorized (player : Session.player) (allowed_players: Session.player set) (error_message : string) : unit =
    assert_with_error (Set.mem player allowed_players) error_message

[@inline]
let check_session_end(result : Session.result) (expected : Session.result) : unit =
    assert_with_error (result = expected) Errors.session_finished

[@inline]
let check_asleep (current_session : Session.t) : unit = 
    assert_with_error (Tezos.now > current_session.asleep) Errors.must_wait_10_min
