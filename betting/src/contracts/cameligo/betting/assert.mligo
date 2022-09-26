#import "types.mligo" "Types"
#import "errors.mligo" "Errors"

// --------------------------------------
//       CONFIG RELATED AssertIONS
// --------------------------------------

let is_manager (p_sender : address)(p_manager : address) : unit =
  if (p_sender <> p_manager)
    then failwith Errors.not_manager

let is_manager_or_oracle (p_sender : address)(p_manager : address)(p_oracle : address) : unit =
  if ((p_sender <> p_manager) && (p_sender <> p_oracle) )
  then failwith Errors.not_manager_nor_oracle

let not_manager_nor_oracle (p_sender : address)(p_manager : address)(p_oracle : address) : unit =
  if ((p_sender = p_manager) || (p_sender = p_oracle) )
  then failwith Errors.bet_as_manager_or_oracle

let not_previous_manager (p_new_manager : address)(p_prev_manager : address) : unit =
  if (p_new_manager = p_prev_manager)
    then failwith Errors.same_previous_manager

let not_previous_oracle (p_new_oracle : address)(p_prev_oracle : address) : unit =
  if (p_new_oracle = p_prev_oracle)
    then failwith Errors.same_previous_oracle_address

// --------------------------------------
//         EVENT RELATED AssertIONS
// --------------------------------------

let event_creation_not_paused (p_event_creation_paused : bool) : unit =
  if (p_event_creation_paused)
    then failwith Errors.event_creation_paused

let event_start_to_end_date (p_event_start : timestamp) (p_event_end : timestamp) : unit =
  if (p_event_start > p_event_end)
    then failwith Errors.event_end_before_start

let event_bet_start_to_end_date (p_event_bet_start : timestamp) (p_event_bet_end : timestamp) : unit =
  if (p_event_bet_start > p_event_bet_end)
    then failwith Errors.event_betting_end_before_start

let event_bet_start_after_end (p_event_bet_start : timestamp) (p_event_end : timestamp) : unit =
  if (p_event_bet_start > p_event_end)
    then failwith Errors.event_betting_start_after_end

let event_bet_ends_after_end (p_event_bet_end : timestamp) (p_event_end : timestamp) : unit =
  if (p_event_bet_end > p_event_end)
    then failwith Errors.event_betting_end_after_end

// --------------------------------------
//         BETTING RELATED AssertIONS
// --------------------------------------

let betting_not_paused (p_betting_paused : bool) : unit =
  if (p_betting_paused)
    then failwith Errors.betting_paused

let betting_not_finalized (p_s : Types.game_status) : unit = match p_s with 
  | Ongoing  -> ()
  | _        -> failwith Errors.bet_finished

let betting_finalized (p_s : Types.game_status) : unit = match p_s with 
  | Ongoing  -> failwith Errors.bet_not_finished
  | _        -> ()

let no_tez (p_asserted_amount : tez) : unit =
  if (p_asserted_amount = 0mutez)
    then failwith Errors.bet_with_no_tez

let tez_lower_than_min (p_asserted_amount : tez)(p_asserted_min_value : tez) : unit =
  if (p_asserted_amount < p_asserted_min_value)
    then failwith Errors.bet_lower_than_minimum

let betting_before_period_start (p_start_at : timestamp) : unit =
  if (p_start_at > (Tezos.get_now()) )
    then failwith Errors.bet_period_not_started

let betting_after_period_end (p_end_at : timestamp) : unit =
  if (p_end_at < (Tezos.get_now()) )
    then failwith Errors.bet_period_finished

let finalizing_before_period_end (p_end_at : timestamp) : unit =
  if (p_end_at > (Tezos.get_now()) )
    then failwith Errors.bet_period_not_finished
    
let bet_is_draw (p_is_draw : bool) : unit =
  if (p_is_draw)
    then failwith Errors.bet_ended_as_draw

