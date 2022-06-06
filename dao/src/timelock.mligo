#import "./errors.mligo" "Errors"

type t =
    [@layout:comb]
    {
        unlock_at: timestamp;
        (* ^ timestamp for the unlock to happen *)

        relock_at: timestamp;
        (* ^ timestamp for the relock to happen *)
    }

(**
    [make(unlock_at, timelock_period)] creates a timelock that holds the given
    [unlock_at] timestamp and compute a relock_at timestamp equals to the
    [timelock_period] added to [unlock_at]
*)
let make (unlock_at, timelock_period : timestamp * nat) : t =
    {
       unlock_at = unlock_at;
       relock_at = unlock_at + int(timelock_period);
    }

(**
    [is_locked(t)] returns true if [t] timelock is locked, false otherwise.
    The timelock in unlocked for a period starting at unlock_at timestamp until relock_at timestamp.
    These timestamps are compared against the current block minimal injection time.
    See https://tezos.gitlab.io/michelson-reference/#instr-NOW
*)
let is_locked (t : t) = ((Tezos.now < t.unlock_at) || (Tezos.now >= t.relock_at))

(**
    [_check_unlocked(t_opt)] checks that a [t_opt] timelock exists and is unlocked
    Raises [Errors.timelock_not_found] if the timelock does not exists.
    Raises [Errors.timelock_locked] if the timelock is locked.
*)
let _check_unlocked (t_opt : t option) =
    match t_opt with
        None -> failwith Errors.timelock_not_found
        | Some(t) -> assert_with_error
            (not is_locked(t))
            Errors.timelock_locked

(**
    [_check_locked(t_opt)] checks that a [t_opt] timelock exists and is locked
    Raises [Errors.timelock_not_found] if the timelock does not exists.
    Raises [Errors.timelock_unlocked] if the timelock is unlocked.
*)
let _check_locked (t_opt : t option) =
    match t_opt with
        None -> failwith Errors.timelock_not_found
        | Some(t) -> assert_with_error
            (is_locked(t))
            Errors.timelock_unlocked
