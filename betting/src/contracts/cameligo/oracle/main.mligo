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

let changeSigner (newSigner : address)( s : TYPES.storage) : (operation list * TYPES.storage) =
  let sender = Tezos.get_sender() in
  if (sender = s.manager)
  then
  (
    if (newSigner <> s.signer)
    then (([] : operation list), {s with signer = newSigner})
    else failwith ERRORS.same_previous_signer
  )
  else failwith ERRORS.not_manager

let switchPause (s : TYPES.storage) : (operation list * TYPES.storage) =
  let sender = Tezos.get_sender() in
  if (sender = s.manager)
  then
  (
    if (s.isPaused)
    then (([] : operation list), {s with isPaused = false})
    else (([] : operation list), {s with isPaused = true})
  )
  else failwith ERRORS.not_manager

let incrementEventIndex (s : TYPES.storage) : (operation list * TYPES.storage) =
  let new_events_index : nat = s.events_index + 1n in
  (([] : operation list), {s with events_index = new_events_index})

let addEvent (newEvent : TYPES.eventType)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let sender = Tezos.get_sender() in
  if ((sender = s.manager) || (sender = s.signer) )
  then
  (
    let ( _ , s) = incrementEventIndex(s) in
    let newEvents : (nat, TYPES.eventType) map = (Map.add (s.events_index) newEvent s.events) in
    (([] : operation list), {s with events = newEvents})
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
  if ((sender = s.manager) || (sender = s.signer) )
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

let main (params, s : TYPES.action * TYPES.storage) : (operation list * TYPES.storage) =
  let result =
    match params with
    | ChangeManager a -> changeManager a s
    | ChangeSigner a -> changeSigner a s
    | SwitchPause _ -> switchPause s
    | AddEvent e -> addEvent e s
    | GetEvent p -> getEvent p.requestedEventID p.callback s
    | UpdateEvent p -> updateEvent p.updatedEventID p.updatedEvent s
  in
  result

[@view]
let getManager (_, s : unit * TYPES.storage) : timestamp * address =
  (Tezos.get_now(), s.manager)

[@view]
let getSigner (_, s : unit * TYPES.storage) : timestamp * address =
  (Tezos.get_now(), s.signer)

[@view]
let getStatus (_, s : unit * TYPES.storage) : timestamp * bool =
  (Tezos.get_now(), s.isPaused)
