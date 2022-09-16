#import "types.mligo" "Types"
#import "assert.mligo" "Assert"
#import "errors.mligo" "Errors"
#import "callback/main.mligo" "Callback"

let change_manager (new_manager : address)( s : Types.storage) : (operation list * Types.storage) =
  let _ = Assert.is_manager (Tezos.get_sender()) s.manager in
  let _ = Assert.not_previous_manager new_manager s.manager in
  (([] : operation list), {s with manager = new_manager})

let switch_pause (s : Types.storage) : (operation list * Types.storage) =
  let _ = Assert.is_manager (Tezos.get_sender()) s.manager in
  if (s.isPaused)
    then (([] : operation list), {s with isPaused = false})
    else (([] : operation list), {s with isPaused = true})

let change_signer (new_signer : address)( s : Types.storage) : (operation list * Types.storage) =
  let _ = Assert.is_manager__or_signer (Tezos.get_sender()) s.manager s.signer in
  let _ = Assert.not_previous_signer new_signer s.signer in
  (([] : operation list), {s with signer = new_signer})

let add_event (new_event : Types.event_type)(s : Types.storage) : (operation list * Types.storage) =
  let _ = Assert.is_manager__or_signer (Tezos.get_sender()) s.manager s.signer in
  let new_events : (nat, Types.event_type) map = (Map.add (s.events_index) new_event s.events) in
  (([] : operation list), {s with events = new_events; events_index = (s.events_index + 1n)})

let get_event (requested_event_id : nat)(callbackAddr : address)(s : Types.storage) : (operation list * Types.storage) =
  let cbk_event =
    match Map.find_opt requested_event_id s.events with
      Some event -> event
    | None -> (failwith Errors.no_event_id)
    in
  let destination : Callback.requested_event_param contract = 
  match (Tezos.get_entrypoint_opt "%saveEvent" callbackAddr : Callback.requested_event_param contract option) with
  | None -> failwith("Unknown contract")
  | Some ctr -> ctr
  in
  let op : operation = Tezos.transaction cbk_event 0mutez destination in
  ([op], s)

let update_event (updated_event_id : nat)(updated_event : Types.event_type)(s : Types.storage) : (operation list * Types.storage) =
  let _ = Assert.is_manager__or_signer (Tezos.get_sender()) s.manager s.signer in
  let _ : Types.event_type =
    match Map.find_opt updated_event_id s.events with
      Some event -> event
    | None -> (failwith Errors.no_event_id)
  in
  let new_events : (nat, Types.event_type) map = Map.update updated_event_id (Some(updated_event)) s.events in
  (([] : operation list), {s with events = new_events})
  
let main (params, s : Types.action * Types.storage) : (operation list * Types.storage) =
  let result =
    match params with
    | ChangeManager a -> change_manager a s
    | ChangeSigner a -> change_signer a s
    | SwitchPause -> switch_pause s
    | AddEvent e -> add_event e s
    | GetEvent p -> get_event p.requested_event_id p.callback s
    | UpdateEvent p -> update_event p.updated_event_id p.updated_event s
  in
  result

[@view]
let getManager (_, s : unit * Types.storage) : timestamp * address =
  (Tezos.get_now(), s.manager)

[@view]
let getSigner (_, s : unit * Types.storage) : timestamp * address =
  (Tezos.get_now(), s.signer)

[@view]
let getStatus (_, s : unit * Types.storage) : timestamp * bool =
  (Tezos.get_now(), s.isPaused)

[@view]
let getEvent (pRequestedEventID, s : nat * Types.storage) : timestamp * Types.event_type =
  let requestedEvent : Types.event_type = match (Map.find_opt pRequestedEventID s.events) with
    | Some event -> event
    | None -> failwith Errors.no_event_id
  in
  (Tezos.get_now(), requestedEvent)