#import "./types.mligo" "TYPES"
#import "./errors.mligo" "ERRORS"

let changeManager (newManager : address)( s : TYPES.storage) : (operation list * TYPES.storage) =
  let sender = Tezos.get_sender() in
  if (sender = s.manager)
  then
  (
    if (newManager <> s.manager)
    then (([] : operation list), {s with manager = newManager})
    else failwith ERRORS.same_previous_manager
  )
  else failwith ERRORS.not_manager

let switchPauseBetting (s : TYPES.storage) : (operation list * TYPES.storage) =
  let sender = Tezos.get_sender() in
  if (sender = s.manager)
  then
  (
    if (s.betConfig.isBettingPaused)
    then (([] : operation list), {s with betConfig.isBettingPaused = false})
    else (([] : operation list), {s with betConfig.isBettingPaused = true})
  )
  else failwith ERRORS.not_manager

let switchPauseEventCreation (s : TYPES.storage) : (operation list * TYPES.storage) =
  let sender = Tezos.get_sender() in
  if (sender = s.manager)
  then
  (
    if (s.betConfig.isEventCreationPaused)
    then (([] : operation list), {s with betConfig.isEventCreationPaused = false})
    else (([] : operation list), {s with betConfig.isEventCreationPaused = true})
  )
  else failwith ERRORS.not_manager

let changeOracleAddress (newOracleAddress : address)( s : TYPES.storage) : (operation list * TYPES.storage) =
  let sender = Tezos.get_sender() in
  if (sender = s.manager)
  then
  (
    if (newOracleAddress <> s.oracleAddress)
    then (([] : operation list), {s with oracleAddress = newOracleAddress})
    else failwith ERRORS.same_previous_oracleAddress
  )
  else failwith ERRORS.not_manager

let changeConfigType (newBetConfig : TYPES.betConfigType)( s : TYPES.storage) : (operation list * TYPES.storage) =
  let sender = Tezos.get_sender() in
  if (sender = s.manager)
  then
  (
    (([] : operation list), {s with betConfig = newBetConfig})
  )
  else failwith ERRORS.not_manager

let incrementEventIndex (s : TYPES.storage) : (operation list * TYPES.storage) =
  let new_events_index : nat = s.events_index + 1n in
  (([] : operation list), {s with events_index = new_events_index})

let addEvent (newEvent : TYPES.eventType)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let sender = Tezos.get_sender() in
  if ((sender = s.manager) || (sender = s.oracleAddress) )
  then
  (
    if (s.betConfig.isEventCreationPaused = false)
    then
    (
      let ( _ , s) = incrementEventIndex(s) in
      let newEvents : (nat, TYPES.eventType) map = (Map.add (s.events_index) newEvent s.events) in
      (([] : operation list), {s with events = newEvents})
    )
    else failwith ERRORS.event_creation_paused
  )
  else failwith ERRORS.not_manager

let getEvent (requestedEventID : nat)(callback : address)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let cbk_event =
    match Map.find_opt requestedEventID s.events with
      Some event -> event
    | None -> (failwith ERRORS.no_event_id)
    in
  let returnedValue : TYPES.callbackReturnedValue = {
    requestedEvent = cbk_event;
    callback = callback;
  } in
  let _operation = Tezos.transaction(returnedValue, 0tez, callback) in
  (([] : operation list), s)

let updateEvent (updatedEventID : nat)(updatedEvent : TYPES.eventType)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let sender = Tezos.get_sender() in
  if ((sender = s.manager) || (sender = s.oracleAddress) )
  then
  (
    let _cbk_event : TYPES.eventType =
      match Map.find_opt updatedEventID s.events with
        Some event -> event
      | None -> (failwith ERRORS.no_event_id)
    in
    let newEvents : (nat, TYPES.eventType) map = Map.update updatedEventID (Some(updatedEvent)) s.events in
    (([] : operation list), {s with events = newEvents})
  )
  else failwith ERRORS.not_manager

let addBet (requestedEventID : nat)(teamOneBet : bool)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let sender : address = Tezos.get_sender() in
  let newstore : TYPES.storage = s in
  if ((sender <> s.manager) && (sender <> s.oracleAddress))
  then
  ( 
    if (Tezos.get_amount() > 0tez)
    then
    (
      if (Tezos.get_amount() >= s.betConfig.minBetAmount)
      then
      (
        let _requestedEvent = match Map.find_opt requestedEventID s.events with
            Some event -> event
          | None -> (failwith ERRORS.no_event_id)
        in
        // let newEventsMap : (nat, TYPES.eventType) map = Map.update requestedEventID (Some(updatedEvent)) s.events in
        (([] : operation list), newstore)
      )
      else failwith ERRORS.bet_lower_than_minimum
    )
    else failwith ERRORS.bet_with_no_tez
  )
  else failwith ERRORS.bet_manager_or_oracle

let main (params, s : TYPES.action * TYPES.storage) : (operation list * TYPES.storage) =
  let result =
    match params with
    | ChangeManager a -> changeManager a s
    | ChangeOracleAddress a -> changeOracleAddress a s
    | SwitchPauseBetting _ -> switchPauseBetting s
    | SwitchPauseEventCreation _ -> switchPauseEventCreation s
    | AddEvent e -> addEvent e s
    | GetEvent p -> getEvent p.requestedEventID p.callback s
    | UpdateEvent p -> updateEvent p.updatedEventID p.updatedEvent s
  in
  result

[@view]
let getManager (_, s : unit * TYPES.storage) : timestamp * address =
  (Tezos.get_now(), s.manager)

[@view]
let getOracleAddress (_, s : unit * TYPES.storage) : timestamp * address =
  (Tezos.get_now(), s.oracleAddress)

[@view]
let getStatus (_, s : unit * TYPES.storage) : timestamp * bool =
  (Tezos.get_now(), s.betConfig.isBettingPaused)
