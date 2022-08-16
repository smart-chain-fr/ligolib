#import "./types.mligo" "TYPES"
#import "./errors.mligo" "ERRORS"

// --------------------------------------
//       CONFIG RELATED ASSERTIONS
// --------------------------------------

let assertManager (pSender : address)(pManager : address) : unit =
  if (pSender <> pManager)
    then failwith ERRORS.not_manager

let assertManagerOracle (pSender : address)(pManager : address)(pOracle : address) : unit =
  if ((pSender <> pManager) && (pSender <> pOracle) )
  then failwith ERRORS.not_manager_or_oracle

let assertNotManagerNorOracle (pSender : address)(pManager : address)(pOracle : address) : unit =
  if ((pSender = pManager) || (pSender = pOracle) )
  then failwith ERRORS.bet_manager_or_oracle

let assertPreviousManager (pNewManager : address)(pPrevManager : address) : unit =
  if (pNewManager = pPrevManager)
    then failwith ERRORS.same_previous_manager

let assertPreviousOracle (pNewOracle : address)(pPrevOracle : address) : unit =
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
    then failwith ERRORS.bet_creation_paused

let assertBettingNotFinished (pBettingFinished : bool) : unit =
  if (pBettingFinished)
    then failwith ERRORS.bet_creation_paused

let assertBettingNotEnded (pBettingPaused : bool) : unit =
  if (pBettingPaused)
    then failwith ERRORS.bet_creation_paused

let assertBetDraw (pAssertedAmount : tez) : unit =
  if (pAssertedAmount = 0tez)
    then failwith ERRORS.bet_with_no_tez

let assertNoTez (pAssertedAmount : tez) : unit =
  if (pAssertedAmount = 0tez)
    then failwith ERRORS.bet_with_no_tez

let assertTezLowerThanMin (pAssertedAmount : tez)(pAssertedMinValue : tez) : unit =
  if (pAssertedAmount < pAssertedMinValue)
    then failwith ERRORS.bet_lower_than_minimum