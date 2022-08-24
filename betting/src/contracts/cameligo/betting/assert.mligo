#import "types.mligo" "TYPES"
#import "errors.mligo" "ERRORS"

// --------------------------------------
//       CONFIG RELATED ASSERTIONS
// --------------------------------------

let assertIsManager (pSender : address)(pManager : address) : unit =
  if (pSender <> pManager)
    then failwith ERRORS.not_manager

let assertIsManagerOrOracle (pSender : address)(pManager : address)(pOracle : address) : unit =
  if ((pSender <> pManager) && (pSender <> pOracle) )
  then failwith ERRORS.not_manager_nor_oracle

let assertNotManagerNorOracle (pSender : address)(pManager : address)(pOracle : address) : unit =
  if ((pSender = pManager) || (pSender = pOracle) )
  then failwith ERRORS.bet_as_manager_or_oracle

let assertNotPreviousManager (pNewManager : address)(pPrevManager : address) : unit =
  if (pNewManager = pPrevManager)
    then failwith ERRORS.same_previous_manager

let assertNotPreviousOracle (pNewOracle : address)(pPrevOracle : address) : unit =
  if (pNewOracle = pPrevOracle)
    then failwith ERRORS.same_previous_oracleAddress

// --------------------------------------
//         EVENT RELATED ASSERTIONS
// --------------------------------------

let assertEventCreationNotPaused (pEventCreationPaused : bool) : unit =
  if (pEventCreationPaused)
    then failwith ERRORS.event_creation_paused

// --------------------------------------
//         BETTING RELATED ASSERTIONS
// --------------------------------------

let assertBettingNotPaused (pBettingPaused : bool) : unit =
  if (pBettingPaused)
    then failwith ERRORS.betting_paused

let assertBettingNotFinalized (pBettingFinalized : bool) : unit =
  if (pBettingFinalized)
    then failwith ERRORS.bet_finished

let assertNoTez (pAssertedAmount : tez) : unit =
  if (pAssertedAmount = 0mutez)
    then failwith ERRORS.bet_with_no_tez

let assertTezLowerThanMin (pAssertedAmount : tez)(pAssertedMinValue : tez) : unit =
  if (pAssertedAmount < pAssertedMinValue)
    then failwith ERRORS.bet_lower_than_minimum

let assertBettingBeforePeriodStart (pStart_at : timestamp) : unit =
  if (pStart_at > (Tezos.get_now()) )
    then failwith ERRORS.bet_period_not_started

let assertBettingAfterPeriodEnd (pEnd_at : timestamp) : unit =
  if (pEnd_at < (Tezos.get_now()) )
    then failwith ERRORS.bet_period_finished

let assertFinalizingBeforePeriodEnd (pEnd_at : timestamp) : unit =
  if (pEnd_at > (Tezos.get_now()) )
    then failwith ERRORS.bet_period_not_finished

let assertBetDraw (pIsDraw : bool) : unit =
  if (pIsDraw)
    then failwith ERRORS.bet_ended_as_draw