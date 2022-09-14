#import "types.mligo" "TYPES"
#import "errors.mligo" "ERRORS"

// --------------------------------------
//       CONFIG RELATED ASSERTIONS
// --------------------------------------

let assert_is_manager (p_sender : address)(p_manager : address) : unit =
  if (p_sender <> p_manager)
    then failwith ERRORS.not_manager

let assert_is_manager_or_oracle (p_sender : address)(p_manager : address)(p_oracle : address) : unit =
  if ((p_sender <> p_manager) && (p_sender <> p_oracle) )
  then failwith ERRORS.not_manager_nor_oracle

let assert_not_manager_nor_oracle (p_sender : address)(p_manager : address)(p_oracle : address) : unit =
  if ((p_sender = p_manager) || (p_sender = p_oracle) )
  then failwith ERRORS.bet_as_manager_or_oracle

let assert_not_previous_manager (p_new_manager : address)(p_prev_manager : address) : unit =
  if (p_new_manager = p_prev_manager)
    then failwith ERRORS.same_previous_manager

let assert_not_previous_oracle (p_new_oracle : address)(p_prev_oracle : address) : unit =
  if (p_new_oracle = p_prev_oracle)
    then failwith ERRORS.same_previous_oracle_address

// --------------------------------------
//         EVENT RELATED ASSERTIONS
// --------------------------------------

let assert_event_creation_not_paused (p_event_creation_paused : bool) : unit =
  if (p_event_creation_paused)
    then failwith ERRORS.event_creation_paused

let assert_event_start_to_end_date (p_event_start : timestamp) (p_event_end : timestamp) : unit =
  if (p_event_start > p_event_end)
    then failwith ERRORS.event_end_before_start

let assert_event_bet_start_to_end_date (p_event_bet_start : timestamp) (p_event_bet_end : timestamp) : unit =
  if (p_event_bet_start > p_event_bet_end)
    then failwith ERRORS.event_betting_end_before_start

let assert_event_bet_start_after_end (p_event_bet_start : timestamp) (p_event_end : timestamp) : unit =
  if (p_event_bet_start > p_event_end)
    then failwith ERRORS.event_betting_start_after_end

let assert_event_bet_ends_after_end (p_event_bet_end : timestamp) (p_event_end : timestamp) : unit =
  if (p_event_bet_end > p_event_end)
    then failwith ERRORS.event_betting_end_after_end

// --------------------------------------
//         BETTING RELATED ASSERTIONS
// --------------------------------------

let assert_betting_not_paused (p_betting_paused : bool) : unit =
  if (p_betting_paused)
    then failwith ERRORS.betting_paused

let assert_betting_not_finalized (p_betting_finalized : bool) : unit =
  if (p_betting_finalized)
    then failwith ERRORS.bet_finished

let assert_betting_finalized (p_betting_finalized : bool) : unit =
  if (not p_betting_finalized)
    then failwith ERRORS.bet_not_finished

let assert_no_tez (p_asserted_amount : tez) : unit =
  if (p_asserted_amount = 0mutez)
    then failwith ERRORS.bet_with_no_tez

let assert_tez_lower_than_min (p_asserted_amount : tez)(p_asserted_min_value : tez) : unit =
  if (p_asserted_amount < p_asserted_min_value)
    then failwith ERRORS.bet_lower_than_minimum

let assert_betting_before_period_start (p_start_at : timestamp) : unit =
  if (p_start_at > (Tezos.get_now()) )
    then failwith ERRORS.bet_period_not_started

let assert_betting_after_period_end (p_end_at : timestamp) : unit =
  if (p_end_at < (Tezos.get_now()) )
    then failwith ERRORS.bet_period_finished

let assert_finalizing_before_period_end (p_end_at : timestamp) : unit =
  if (p_end_at > (Tezos.get_now()) )
    then failwith ERRORS.bet_period_not_finished
    
let assert_bet_is_draw (p_is_draw : bool) : unit =
  if (p_is_draw)
    then failwith ERRORS.bet_ended_as_draw

