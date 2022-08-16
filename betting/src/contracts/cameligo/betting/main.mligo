// Betting & Predictive Market - CameLIGO contract

#import "./types.mligo" "TYPES"
#import "./errors.mligo" "ERRORS"
#import "./assert.mligo" "ASSERT"

// --------------------------------------
//      CONFIGURATION INTERACTIONS
// --------------------------------------

let changeManager (newManager : address)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assertManager (Tezos.get_sender()) s.manager in
  let _ = ASSERT.assertPreviousManager newManager s.manager in
  (([] : operation list), {s with manager = newManager})

let switchPauseBetting (s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assertManager (Tezos.get_sender()) s.manager in
  if (s.betConfig.isBettingPaused)
    then (([] : operation list), {s with betConfig.isBettingPaused = false})
    else (([] : operation list), {s with betConfig.isBettingPaused = true})

let switchPauseEventCreation (s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assertManager (Tezos.get_sender()) s.manager in
  if (s.betConfig.isEventCreationPaused)
    then (([] : operation list), {s with betConfig.isEventCreationPaused = false})
    else (([] : operation list), {s with betConfig.isEventCreationPaused = true})

let changeOracleAddress (newOracleAddress : address)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assertManager (Tezos.get_sender()) s.manager in
  let _ = ASSERT.assertPreviousOracle newOracleAddress s.oracleAddress in
  (([] : operation list), {s with oracleAddress = newOracleAddress})

let changeConfigType (newBetConfig : TYPES.betConfigType)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assertManager (Tezos.get_sender()) s.manager in
  (([] : operation list), {s with betConfig = newBetConfig})

// --------------------------------------
//           INTERNAL FUNCTIONS
// --------------------------------------

let _incrementEventIndex (s : TYPES.storage) : (operation list * TYPES.storage) =
  (([] : operation list), {s with events_index = (s.events_index + 1n)})

// --------------------------------------
//          EVENT INTERACTIONS
// --------------------------------------

let addEvent (newEvent : TYPES.eventType)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assertManagerOracle (Tezos.get_sender()) s.manager s.oracleAddress in
  let _ = ASSERT.assertEventCreationNotPaused s.betConfig.isEventCreationPaused in
  let newEvents : (nat, TYPES.eventType) map = (Map.add (s.events_index) newEvent s.events) in
  (([] : operation list), {s with events = newEvents; events_index = (s.events_index + 1n)})

let getEvent (requestedEventID : nat)(callback : address)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let cbk_event = match Map.find_opt requestedEventID s.events with
    | Some event -> event
    | None -> (failwith ERRORS.no_event_id)
    in
  let returnedValue : TYPES.callbackReturnedValue = {
    requestedEvent = cbk_event;
    callback = callback;
  } in
  let _ = Tezos.transaction(returnedValue, 0tez, callback) in
  (([] : operation list), s)

let updateEvent (updatedEventID : nat)(updatedEvent : TYPES.eventType)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assertManagerOracle (Tezos.get_sender()) s.manager s.oracleAddress in
  let _ = match Map.find_opt updatedEventID s.events with
    | Some event -> event
    | None -> (failwith ERRORS.no_event_id)
  in
  let newEvents : (nat, TYPES.eventType) map = Map.update updatedEventID (Some(updatedEvent)) s.events in
  (([] : operation list), {s with events = newEvents})

// --------------------------------------
//         BETTING INTERACTIONS
// --------------------------------------

let addBetAmountToExistingUser (pRequestedEventID : TYPES.eventType)(p_previousAmount : tez) =
  let p_newbetsTeamOne : (address, tez) map = Map.update (Tezos.get_sender()) (Some(p_previousAmount + Tezos.get_amount())) pRequestedEventID.betsTeamOne in
  let p_newbetsTeamOne_index : nat = pRequestedEventID.betsTeamOne_index + 1n in
  (p_newbetsTeamOne, p_newbetsTeamOne_index)

let addBetAmountToNewUser (pRequestedEventID : TYPES.eventType) =
  let p_newbetsTeamOne : (address, tez) map = Map.add (Tezos.get_sender()) (Tezos.get_amount()) pRequestedEventID.betsTeamOne in
  (p_newbetsTeamOne, pRequestedEventID.betsTeamOne_index)

let addBetTeamOne (pRequestedEventID : TYPES.eventType) : TYPES.eventType =
  let (newbetsTeamOne, newbetsTeamOne_index) : ((address, tez) map * nat) = match (Map.find_opt (Tezos.get_sender()) pRequestedEventID.betsTeamOne) with
    | Some prevAmount -> addBetAmountToExistingUser pRequestedEventID prevAmount
    | None -> addBetAmountToNewUser pRequestedEventID
  in
  let newbetsTeamOne_total : tez = (pRequestedEventID.betsTeamOne_total + Tezos.get_amount()) in
  let r_updatedEvent : TYPES.eventType = {pRequestedEventID with betsTeamOne = newbetsTeamOne; betsTeamOne_index = newbetsTeamOne_index; betsTeamOne_total = newbetsTeamOne_total;} in
  (r_updatedEvent)

let addBetTeamTwo (pRequestedEventID : TYPES.eventType) : TYPES.eventType =
  let (newbetsTeamTwo, newbetsTeamTwo_index) : ((address, tez) map * nat) = match (Map.find_opt (Tezos.get_sender()) pRequestedEventID.betsTeamTwo) with
    | Some prevAmount -> addBetAmountToExistingUser pRequestedEventID prevAmount
    | None -> addBetAmountToNewUser pRequestedEventID
  in
  let newbetsTeamTwo_total : tez = (pRequestedEventID.betsTeamTwo_total + Tezos.get_amount()) in
  let r_updatedEvent : TYPES.eventType = {pRequestedEventID with betsTeamTwo = newbetsTeamTwo; betsTeamTwo_index = newbetsTeamTwo_index; betsTeamTwo_total = newbetsTeamTwo_total;} in
  (r_updatedEvent)

let addBet (pRequestedEventID : nat)(teamOneBet : bool)(s : TYPES.storage) : (operation list * TYPES.storage) =
  // TO DO : verify the state of the bet (Finished, Paused, Bet Period)
  let _ = ASSERT.assertManagerOracle (Tezos.get_sender()) s.manager s.oracleAddress in
  let _ = ASSERT.assertNoTez (Tezos.get_amount()) in
  let _ = ASSERT.assertTezLowerThanMin (Tezos.get_amount()) s.betConfig.minBetAmount in
  let requestedEvent : TYPES.eventType = match (Map.find_opt pRequestedEventID s.events) with
    | Some event -> event
    | None -> failwith ERRORS.no_event_id
  in
  let _ = ASSERT.assertBettingNotFinished (requestedEvent.isFinished) in
  let updatedEvent = if (teamOneBet)
    then ( let uEvent : TYPES.eventType = addBetTeamOne requestedEvent in (uEvent) )
    else ( let uEvent : TYPES.eventType = addBetTeamTwo requestedEvent in (uEvent) )
  in
  let newEventsMap : (nat, TYPES.eventType) map = (Map.update pRequestedEventID (Some(updatedEvent)) s.events) in
  (([] : operation list), {s with events = newEventsMap;})

// let rewardBetWinners (pListWinners : (address, tez) map) =
//   let trscRewardBetWinners = fun (i,j : address * tez) -> Tezos.transaction((), 1tez, i) in
//   Map.map trscRewardBetWinners pListWinners 

// let rewardBetWinners (pListWinners : (address, tez) map) =
//   let trscRewardBetWinners (addr : address) = Tezos.transaction((), 1tez, addr) in
//   Map.fold trscRewardBetWinners pListWinners

// let rewardBetWinners (pListWinners : (address, tez) map) =
//   let trscRewardBetWinners =
//     fun (i, j : address * tez) -> Tezos.transaction((), 1tez, i)
//   in
//   let _ = Map.iter trscRewardBetWinners pListWinners in
//   ()

// let trscRewardBetWinners (i, j : address * tez) = 
//     let _ = Tezos.transaction((), 1tez, i) in
//     ()

// let rewardBetWinners (pListWinners : (address, tez) map) =
//   let _ = Map.iter trscRewardBetWinners pListWinners in
//   ()

let trsRewardBetWinners (pWinner : address)(pBetAmount : tez) : unit =
  let _ = Tezos.transaction((), pBetAmount, pWinner) in
  ()

let rewardBetWinners (pWinnersMap : (address, tez) map) =
  let predicate = fun (iWinner, jBetAmount : address * tez) -> trsRewardBetWinners iWinner jBetAmount in
  let _ = Map.iter predicate pWinnersMap in
  ()

let finalizeBet (pRequestedEventID : nat)(s : TYPES.storage) : (operation list * TYPES.storage) =
  // TO DO : verify the state of the bet (Finished, Paused, Bet Period) and pay users
  let _ = ASSERT.assertManager (Tezos.get_sender()) s.manager in
  let requestedEvent : TYPES.eventType = match (Map.find_opt pRequestedEventID s.events) with
    | Some event -> event
    | None -> failwith ERRORS.no_event_id
  in
  let _ = ASSERT.assertBettingNotFinished (requestedEvent.isFinished) in
  let updatedEvent : TYPES.eventType = {requestedEvent with isFinished = true} in
  let outcomeTeamOneWin : bool = match updatedEvent.isTeamOneWin with
    | Some x -> x
    | None -> failwith ERRORS.bet_no_event_outcome
  in
  let _ = if (outcomeTeamOneWin)
    then ( rewardBetWinners updatedEvent.betsTeamOne )
    else ( rewardBetWinners updatedEvent.betsTeamTwo )
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
    | SwitchPauseBetting _ -> switchPauseBetting s
    | SwitchPauseEventCreation _ -> switchPauseEventCreation s
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
let getStatus (_, s : unit * TYPES.storage) : timestamp * bool =
  (Tezos.get_now(), s.betConfig.isBettingPaused)
