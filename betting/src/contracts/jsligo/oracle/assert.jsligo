#import "types.mligo" "Types"
#import "errors.mligo" "Errors"

// --------------------------------------
//       CONFIG RELATED AssertIONS
// --------------------------------------

let is_manager (p_sender : address)(p_manager : address) : unit =
  if (p_sender <> p_manager)
    then failwith Errors.not_manager

let is_manager__or_signer (p_sender : address)(p_manager : address)(p_signer : address) : unit =
  if ((p_sender <> p_manager) && (p_sender <> p_signer) )
  then failwith Errors.not_manager_nor_signer

let not_previous_manager (p_new_manager : address)(p_prev_manager : address) : unit =
  if (p_new_manager = p_prev_manager)
    then failwith Errors.same_previous_manager

let not_previous_signer (p_new_signer : address)(p_prev_signer : address) : unit =
  if (p_new_signer = p_prev_signer)
    then failwith Errors.same_previous_signer

let event_creation_not_paused (p_event_creation_paused : bool) : unit =
  if (p_event_creation_paused)
    then failwith Errors.event_creation_paused