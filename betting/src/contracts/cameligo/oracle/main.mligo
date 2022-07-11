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

let addEvent (newEvent : TYPES.oracleEventType)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let newEvents : (nat, TYPES.oracleEventType) map = Map.add (s.events_index + 1n) newEvent s.events in
  (([] : operation list), {s with events = newEvents})


let getEvent (_requestedEventID : nat)(s : TYPES.storage) : (operation list * TYPES.storage) =
  (([] : operation list), s)

// let getEvent (requestedEventID, cbk_addr : nat * address)(s : TYPES.storage) : (operation list * TYPES.storage) =
//   let callback = cbk_addr in
//   let returnedValue : TYPES.callbackReturnedValue = {
//     requestedEvent = requestedEventID;
//     callback = cbk_addr;
//   } in
//   let _operation = Tezos.transaction(returnedValue, 0tez, callback) in
//   (([] : operation list), s)

let updateEvent (_newValue : nat)(s : TYPES.storage) : (operation list * TYPES.storage) =
  (([] : operation list), s)

let main (params, s : TYPES.action * TYPES.storage) : (operation list * TYPES.storage) =
  let result =
    match params with
    | ChangeManager p -> changeManager p s
    | ChangeSigner p -> changeSigner p s
    | SwitchPause _ -> switchPause s
    | AddEvent p -> addEvent p s
    | GetEvent p -> getEvent p s
    // | GetEvent (p,q) -> getEvent (p,q) s
    | UpdateEvent p -> updateEvent p s
  in
  result

[@view]
let getStatus (_, s : unit * TYPES.storage) : timestamp * bool =
  (Tezos.get_now(), s.isPaused)
