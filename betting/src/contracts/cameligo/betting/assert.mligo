#import "types.mligo" "TYPES"
#import "errors.mligo" "ERRORS"

// --------------------------------------
//       CONFIG RELATED ASSERTIONS
// --------------------------------------

let assert_is_manager (pSender : address)(pManager : address) : unit =
  if (pSender <> pManager)
    then failwith ERRORS.not_manager

let assert_is_manager_or_oracle (pSender : address)(pManager : address)(pOracle : address) : unit =
  if ((pSender <> pManager) && (pSender <> pOracle) )
  then failwith ERRORS.not_manager_nor_oracle

let assert_not_manager_nor_oracle (pSender : address)(pManager : address)(pOracle : address) : unit =
  if ((pSender = pManager) || (pSender = pOracle) )
  then failwith ERRORS.bet_as_manager_or_oracle

let assert_not_previous_manager (pNewManager : address)(pPrevManager : address) : unit =
  if (pNewManager = pPrevManager)
    then failwith ERRORS.same_previous_manager

let assert_not_previous_oracle (pNewOracle : address)(pPrevOracle : address) : unit =
  if (pNewOracle = pPrevOracle)
    then failwith ERRORS.same_previous_oracleAddress

// --------------------------------------
//         EVENT RELATED ASSERTIONS
// --------------------------------------

let assert_event_creation_not_paused (pEventCreationPaused : bool) : unit =
  if (pEventCreationPaused)
    then failwith ERRORS.event_creation_paused

let assert_event_start_to_end_date (pEventStart : timestamp) (pEventEnd : timestamp) : unit =
  if (pEventStart > pEventEnd)
    then failwith ERRORS.event_end_before_start

let assert_event_bet_start_to_end_date (pevent_betstart : timestamp) (pEventBetEnd : timestamp) : unit =
  if (pevent_betstart > pEventBetEnd)
    then failwith ERRORS.event_betting_end_before_start

let assert_event_bet_start_after_end (pevent_betstart : timestamp) (pEventEnd : timestamp) : unit =
  if (pevent_betstart > pEventEnd)
    then failwith ERRORS.event_betting_start_after_end

let assert_event_bet_ends_after_end (pEventBetEnd : timestamp) (pEventEnd : timestamp) : unit =
  if (pEventBetEnd > pEventEnd)
    then failwith ERRORS.event_betting_end_after_end

// --------------------------------------
//         BETTING RELATED ASSERTIONS
// --------------------------------------

let assert_betting_not_paused (pBettingPaused : bool) : unit =
  if (pBettingPaused)
    then failwith ERRORS.betting_paused

let assert_betting_not_finalized (pBettingFinalized : bool) : unit =
  if (pBettingFinalized)
    then failwith ERRORS.bet_finished

let assert_no_tez (pAssertedAmount : tez) : unit =
  if (pAssertedAmount = 0mutez)
    then failwith ERRORS.bet_with_no_tez

let assert_tez_lower_than_min (pAssertedAmount : tez)(pAssertedMinValue : tez) : unit =
  if (pAssertedAmount < pAssertedMinValue)
    then failwith ERRORS.bet_lower_than_minimum

let assert_betting_before_period_start (pStart_at : timestamp) : unit =
  if (pStart_at > (Tezos.get_now()) )
    then failwith ERRORS.bet_period_not_started

let assert_betting_after_period_end (pEnd_at : timestamp) : unit =
  if (pEnd_at < (Tezos.get_now()) )
    then failwith ERRORS.bet_period_finished

let assert_finalizing_before_period_end (pEnd_at : timestamp) : unit =
  if (pEnd_at > (Tezos.get_now()) )
    then failwith ERRORS.bet_period_not_finished

let assert_bet_is_draw (pIsDraw : bool) : unit =
  if (pIsDraw)
    then failwith ERRORS.bet_ended_as_draw