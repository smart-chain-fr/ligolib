#import "types.mligo" "TYPES"
#import "assert.mligo" "ASSERT"
#import "errors.mligo" "ERRORS"

let change_manager (newManager : address)( s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assert_is_manager (Tezos.get_sender()) s.manager in
  let _ = ASSERT.assert_not_previous_manager newManager s.manager in
  (([] : operation list), {s with manager = newManager})

let switch_pause (s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assert_is_manager (Tezos.get_sender()) s.manager in
  if (s.isPaused)
    then (([] : operation list), {s with isPaused = false})
    else (([] : operation list), {s with isPaused = true})

let change_signer (newSigner : address)( s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assert_is_manager__or_signer (Tezos.get_sender()) s.manager s.signer in
  let _ = ASSERT.assert_not_previous_signer newSigner s.signer in
  (([] : operation list), {s with signer = newSigner})

let add_event (newEvent : TYPES.event_type)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assert_is_manager__or_signer (Tezos.get_sender()) s.manager s.signer in
  let newEvents : (nat, TYPES.event_type) map = (Map.add (s.events_index) newEvent s.events) in
  (([] : operation list), {s with events = newEvents; events_index = (s.events_index + 1n)})

let get_event (requestedEventID : nat)(callback : address)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let cbk_event =
    match Map.find_opt requestedEventID s.events with
      Some event -> event
    | None -> (failwith ERRORS.no_event_id)
    in
  let returnedValue : TYPES.callback_returned_value = {
    requestedEvent = cbk_event;
    callback = callback;
  } in
  let _operation = Tezos.transaction(returnedValue, 0mutez, callback) in
  (([] : operation list), s)

let update_event (updatedEventID : nat)(updatedEvent : TYPES.event_type)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assert_is_manager__or_signer (Tezos.get_sender()) s.manager s.signer in
  let _cbk_event : TYPES.event_type =
    match Map.find_opt updatedEventID s.events with
      Some event -> event
    | None -> (failwith ERRORS.no_event_id)
  in
  let newEvents : (nat, TYPES.event_type) map = Map.update updatedEventID (Some(updatedEvent)) s.events in
  (([] : operation list), {s with events = newEvents})
  
let main (params, s : TYPES.action * TYPES.storage) : (operation list * TYPES.storage) =
  let result =
    match params with
    | ChangeManager a -> change_manager a s
    | ChangeSigner a -> change_signer a s
    | SwitchPause -> switch_pause s
    | AddEvent e -> add_event e s
    | GetEvent p -> get_event p.requestedEventID p.callback s
    | UpdateEvent p -> update_event p.updatedEventID p.updatedEvent s
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

[@view]
let getEvent (pRequestedEventID, s : nat * TYPES.storage) : timestamp * TYPES.event_type =
  let requestedEvent : TYPES.event_type = match (Map.find_opt pRequestedEventID s.events) with
    | Some event -> event
    | None -> failwith ERRORS.no_event_id
  in
  (Tezos.get_now(), requestedEvent)