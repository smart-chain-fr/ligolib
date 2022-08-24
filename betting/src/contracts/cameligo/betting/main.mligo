// Betting & Predictive Market - CameLIGO contract

#import "types.mligo" "TYPES"
#import "errors.mligo" "ERRORS"
#import "assert.mligo" "ASSERT"

// --------------------------------------
//      CONFIGURATION INTERACTIONS
// --------------------------------------

let changeManager (newManager : address)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assertIsManager (Tezos.get_sender()) s.manager in
  let _ = ASSERT.assertNotPreviousManager newManager s.manager in
  (([] : operation list), {s with manager = newManager})

let switchPauseBetting (s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assertIsManager (Tezos.get_sender()) s.manager in
  if (s.betConfig.isBettingPaused)
    then (([] : operation list), {s with betConfig.isBettingPaused = false})
    else (([] : operation list), {s with betConfig.isBettingPaused = true})

let switchPauseEventCreation (s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assertIsManager (Tezos.get_sender()) s.manager in
  if (s.betConfig.isEventCreationPaused)
    then (([] : operation list), {s with betConfig.isEventCreationPaused = false})
    else (([] : operation list), {s with betConfig.isEventCreationPaused = true})

let changeOracleAddress (newOracleAddress : address)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assertIsManager (Tezos.get_sender()) s.manager in
  let _ = ASSERT.assertNotPreviousOracle newOracleAddress s.oracleAddress in
  (([] : operation list), {s with oracleAddress = newOracleAddress})

let changeConfigType (newBetConfig : TYPES.betConfigType)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assertIsManager (Tezos.get_sender()) s.manager in
  (([] : operation list), {s with betConfig = newBetConfig})


// --------------------------------------
//          EVENT INTERACTIONS
// --------------------------------------

let addEvent (newEvent : TYPES.eventType)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assertIsManagerOrOracle (Tezos.get_sender()) s.manager s.oracleAddress in
  let _ = ASSERT.assertEventCreationNotPaused s.betConfig.isEventCreationPaused in
  let newEvents : (nat, TYPES.eventType) map = (Map.add (s.events_index) newEvent s.events) in
  let newEventBet : TYPES.eventBets = {
    betsTeamOne = (Map.empty : (address, tez) map);
    betsTeamOne_index = 0n;
    betsTeamOne_total = 0mutez;
    betsTeamTwo = (Map.empty : (address, tez) map);
    betsTeamTwo_index = 0n;
    betsTeamTwo_total = 0mutez;
  } in
  let newEventsBets : (nat, TYPES.eventBets) map = (Map.add (s.events_index) newEventBet s.events_bets) in
  (([] : operation list), {s with events = newEvents; events_bets = newEventsBets; events_index = (s.events_index + 1n)})

let getEvent (requestedEventID : nat)(callback : address)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let cbk_event = match Map.find_opt requestedEventID s.events with
    | Some event -> event
    | None -> (failwith ERRORS.no_event_id)
    in
  let cbk_eventbet = match Map.find_opt requestedEventID s.events_bets with
    | Some eventbet -> eventbet
    | None -> (failwith ERRORS.no_event_id)
    in
  let returnedValue : TYPES.callbackReturnedValue = {
    requestedEvent = {
      name = cbk_event.name;
      videogame = cbk_event.videogame;
      begin_at = cbk_event.begin_at;
      end_at = cbk_event.end_at;
      modified_at = cbk_event.modified_at;
      opponents = { teamOne = cbk_event.opponents.teamOne; teamTwo = cbk_event.opponents.teamTwo};
      isFinalized = cbk_event.isFinalized;
      isDraw = cbk_event.isDraw;
      isTeamOneWin = cbk_event.isTeamOneWin;
      startBetTime = cbk_event.startBetTime;
      closedBetTime = cbk_event.closedBetTime;
      betsTeamOne = cbk_eventbet.betsTeamOne;
      betsTeamOne_index = cbk_eventbet.betsTeamOne_index;
      betsTeamOne_total = cbk_eventbet.betsTeamOne_total;
      betsTeamTwo = cbk_eventbet.betsTeamTwo;
      betsTeamTwo_index = cbk_eventbet.betsTeamTwo_index;
      betsTeamTwo_total = cbk_eventbet.betsTeamTwo_total;
    };
    callback = callback;
  } in
  let _ = Tezos.transaction(returnedValue, 0mutez, callback) in
  (([] : operation list), s)

let updateEvent (updatedEventID : nat)(updatedEvent : TYPES.eventType)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assertIsManagerOrOracle (Tezos.get_sender()) s.manager s.oracleAddress in
  let _ = match Map.find_opt updatedEventID s.events with
    | Some event -> event
    | None -> (failwith ERRORS.no_event_id)
  in
  let newEvents : (nat, TYPES.eventType) map = Map.update updatedEventID (Some(updatedEvent)) s.events in
  (([] : operation list), {s with events = newEvents})

// --------------------------------------
//         BETTING INTERACTIONS
// --------------------------------------

let addBetTeamOneAmountToExistingUser (pRequestedEventID : TYPES.eventBets)(pPreviousAmount : tez) =
  let p_newbetsTeamOne : (address, tez) map = Map.update (Tezos.get_sender()) (Some(pPreviousAmount + Tezos.get_amount())) pRequestedEventID.betsTeamOne in
  (p_newbetsTeamOne, pRequestedEventID.betsTeamOne_index)

let addBetTeamOneAmountToNewUser (pRequestedEventID : TYPES.eventBets) =
  let p_newbetsTeamOne : (address, tez) map = Map.add (Tezos.get_sender()) (Tezos.get_amount()) pRequestedEventID.betsTeamOne in
  let p_newbetsTeamOne_index : nat = (pRequestedEventID.betsTeamOne_index + 1n) in
  (p_newbetsTeamOne, p_newbetsTeamOne_index)

let addBetTeamOne (pRequestedEventID : TYPES.eventBets) : TYPES.eventBets =
  let (newbetsTeamOne, newbetsTeamOne_index) : ((address, tez) map * nat) = match (Map.find_opt (Tezos.get_sender()) pRequestedEventID.betsTeamOne) with
    | Some prevAmount -> addBetTeamOneAmountToExistingUser pRequestedEventID prevAmount
    | None -> addBetTeamOneAmountToNewUser pRequestedEventID
  in
  let newbetsTeamOne_total : tez = (pRequestedEventID.betsTeamOne_total + Tezos.get_amount()) in
  let r_updatedEvent : TYPES.eventBets = {pRequestedEventID with betsTeamOne = newbetsTeamOne; betsTeamOne_index = newbetsTeamOne_index; betsTeamOne_total = newbetsTeamOne_total;} in
  (r_updatedEvent)


let addBetTeamTwoAmountToExistingUser (pRequestedEventID : TYPES.eventBets)(pPreviousAmount : tez) =
  let p_newbetsTeamTwo : (address, tez) map = Map.update (Tezos.get_sender()) (Some(pPreviousAmount + Tezos.get_amount())) pRequestedEventID.betsTeamTwo in
  (p_newbetsTeamTwo, pRequestedEventID.betsTeamTwo_index)

let addBetTeamTwoAmountToNewUser (pRequestedEventID : TYPES.eventBets) =
  let p_newbetsTeamTwo : (address, tez) map = Map.add (Tezos.get_sender()) (Tezos.get_amount()) pRequestedEventID.betsTeamTwo in
  let p_newbetsTeamTwo_index : nat = (pRequestedEventID.betsTeamTwo_index + 1n) in
  (p_newbetsTeamTwo, p_newbetsTeamTwo_index)

let addBetTeamTwo (pRequestedEventID : TYPES.eventBets) : TYPES.eventBets =
  let (newbetsTeamTwo, newbetsTeamTwo_index) : ((address, tez) map * nat) = match (Map.find_opt (Tezos.get_sender()) pRequestedEventID.betsTeamTwo) with
    | Some prevAmount -> addBetTeamTwoAmountToExistingUser pRequestedEventID prevAmount
    | None -> addBetTeamTwoAmountToNewUser pRequestedEventID
  in
  let newbetsTeamTwo_total : tez = (pRequestedEventID.betsTeamTwo_total + Tezos.get_amount()) in
  let r_updatedEvent : TYPES.eventBets = {pRequestedEventID with betsTeamTwo = newbetsTeamTwo; betsTeamTwo_index = newbetsTeamTwo_index; betsTeamTwo_total = newbetsTeamTwo_total;} in
  (r_updatedEvent)

let addBet (pRequestedEventID : nat)(teamOneBet : bool)(s : TYPES.storage) : (operation list * TYPES.storage) =
  // TO DO : verify the state of the bet (Finished, Paused, Bet Period)
  let _ = ASSERT.assertNotManagerNorOracle (Tezos.get_sender()) s.manager s.oracleAddress in
  let _ = ASSERT.assertNoTez (Tezos.get_amount()) in
  let _ = ASSERT.assertTezLowerThanMin (Tezos.get_amount()) s.betConfig.minBetAmount in
  let requestedEvent : TYPES.eventType = match (Map.find_opt pRequestedEventID s.events) with
    | Some event -> event
    | None -> failwith ERRORS.no_event_id
  in
  let requestedEventBets : TYPES.eventBets = match (Map.find_opt pRequestedEventID s.events_bets) with
    | Some event -> event
    | None -> failwith ERRORS.no_event_bets
  in
  let _ = ASSERT.assertBettingNotFinalized (requestedEvent.isFinalized) in
  let _ = ASSERT.assertBettingBeforePeriodStart (requestedEvent.begin_at) in
  let _ = ASSERT.assertBettingAfterPeriodEnd (requestedEvent.end_at) in
  let updatedBetEvent : TYPES.eventBets = if (teamOneBet)
    then ( let uEvent : TYPES.eventBets = addBetTeamOne requestedEventBets in (uEvent) )
    else ( let uEvent : TYPES.eventBets = addBetTeamTwo requestedEventBets in (uEvent) )
  in
  let newEventsMap : (nat, TYPES.eventBets) map = (Map.update pRequestedEventID (Some(updatedBetEvent)) s.events_bets) in
  (([] : operation list), {s with events_bets = newEventsMap;})

let trsRewardBetWinners (pRequestedEventBets : TYPES.eventBets)(pWinner : address)(pBetAmount : tez)(s : TYPES.storage) : unit =
  // TO DO : Make sure the rewards match the expected amount
  let initialAmount : tez = match (pBetAmount - ((pBetAmount * s.betConfig.retainedProfitQuota) / 100n)) with
    | Some tezAmount -> tezAmount
    | None -> failwith ERRORS.bet_reward_incorrect
  in
  let opponentAmount : tez = (pRequestedEventBets.betsTeamOne_total / pRequestedEventBets.betsTeamOne_index) in
  let finalAmount : tez = (initialAmount + opponentAmount) in
  let _ = Tezos.transaction((), finalAmount, pWinner) in
  ()

let rewardBetWinners (pRequestedEventBets : TYPES.eventBets)(pWinnersMap : (address, tez) map)(s : TYPES.storage) : unit =
// TO DO : Make sure the rewards match the expected amount
  let calculate = fun (iWinner, jBetAmount : address * tez) -> trsRewardBetWinners pRequestedEventBets iWinner jBetAmount s in
  let _ = Map.iter calculate pWinnersMap in
  ()

let trsRewardBetDraw (pWinner : address)(pBetAmount : tez)(s : TYPES.storage) : unit =
  // TO DO : Make sure the rewards match the expected amount
  let _ = Tezos.transaction((), (pBetAmount - ((pBetAmount * s.betConfig.retainedProfitQuota) / 100n)), pWinner) in
  ()

let refundBetPlayers (pTeamOneMap : (address, tez) map)(pTeamTwoMap : (address, tez) map)(s : TYPES.storage) : unit =
// TO DO : Make sure the rewards match the expected amount
  let calculate = fun (dPlayer, dBetAmount : address * tez) -> trsRewardBetDraw dPlayer dBetAmount s in
  let _ = Map.iter calculate pTeamOneMap in
  let _ = Map.iter calculate pTeamTwoMap in
  ()

let finalizeBet (pRequestedEventID : nat)(s : TYPES.storage) : (operation list * TYPES.storage) =
  // TO DO : verify the state of the bet (Finished, Paused, Bet Period) and rewards users accordingly
  let _ = ASSERT.assertIsManager (Tezos.get_sender()) s.manager in
  let requestedEvent : TYPES.eventType = match (Map.find_opt pRequestedEventID s.events) with
    | Some event -> event
    | None -> failwith ERRORS.no_event_id
  in
  let requestedEventBets : TYPES.eventBets = match (Map.find_opt pRequestedEventID s.events_bets) with
    | Some event -> event
    | None -> failwith ERRORS.no_event_bets
  in
  let _ = ASSERT.assertBettingNotFinalized (requestedEvent.isFinalized) in
  let _ = ASSERT.assertFinalizingBeforePeriodEnd (requestedEvent.end_at) in
  let updatedEvent : TYPES.eventType = {requestedEvent with isFinalized = true} in
  let outcomeDraw : bool = match requestedEvent.isDraw with
    | Some x -> x
    | None -> failwith ERRORS.bet_no_team_outcome
  in
  let _ = if (outcomeDraw)
    then (refundBetPlayers requestedEventBets.betsTeamOne requestedEventBets.betsTeamTwo s)
    else (
      let outcomeTeamOneWin : bool = match requestedEvent.isTeamOneWin with
        | Some x -> x
        | None -> failwith ERRORS.bet_no_team_outcome
      in
      if (outcomeTeamOneWin)
        then ( rewardBetWinners requestedEventBets requestedEventBets.betsTeamOne s )
        else ( rewardBetWinners requestedEventBets requestedEventBets.betsTeamTwo s )
    )
  in
  let newEventsMap : (nat, TYPES.eventType) map = (Map.update pRequestedEventID (Some(updatedEvent)) s.events) in
  (([] : operation list), {s with events = newEventsMap;})

// --------------------------------------
//            MAIN FUNCTION
// --------------------------------------

let main (params, s : TYPES.action * TYPES.storage) : (operation list * TYPES.storage) =
  let result = match params with
    | ChangeManager a -> changeManager a s
    | ChangeOracleAddress a -> changeOracleAddress a s
    | SwitchPauseBetting -> switchPauseBetting s
    | SwitchPauseEventCreation -> switchPauseEventCreation s
    | AddEvent e -> addEvent e s
    | GetEvent p -> getEvent p.requestedEventID p.callback s
    | UpdateEvent p -> updateEvent p.updatedEventID p.updatedEvent s
    | AddBet p -> addBet p.requestedEventID p.teamOneBet s
    | FinalizeBet p -> finalizeBet p s
  in
  result

// --------------------------------------
//            CONTRACT VIEWS
// --------------------------------------

[@view]
let getManager (_, s : unit * TYPES.storage) : timestamp * address =
  (Tezos.get_now(), s.manager)

[@view]
let getOracleAddress (_, s : unit * TYPES.storage) : timestamp * address =
  (Tezos.get_now(), s.oracleAddress)

[@view]
let getBettingStatus (_, s : unit * TYPES.storage) : timestamp * bool =
  (Tezos.get_now(), s.betConfig.isBettingPaused)

[@view]
let getEventCreationStatus (_, s : unit * TYPES.storage) : timestamp * bool =
  (Tezos.get_now(), s.betConfig.isEventCreationPaused)

[@view]
let getEvent (pRequestedEventID, s : nat * TYPES.storage) : timestamp * TYPES.eventType =
  let requestedEvent : TYPES.eventType = match (Map.find_opt pRequestedEventID s.events) with
    | Some event -> event
    | None -> failwith ERRORS.no_event_id
  in
  (Tezos.get_now(), requestedEvent)