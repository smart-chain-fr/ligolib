#import "session.mligo" "Session"

[@inline]
let player_can_play (player: address) (allowed_player: address set): unit =
    assert_with_error (Set.mem player allowed_player) "Not allowed to play in this session"

[@inline]
let right_game_round (current: nat) (expected: nat): unit =
    assert_with_error (current = expected) "Wrong round parameter"

[@inline]
let has_a_valid_session (session: Session.t option): Session.t =
    match session with
    | None -> (failwith("Unknown session") : Session.t)
    | Some (sess) -> sess
