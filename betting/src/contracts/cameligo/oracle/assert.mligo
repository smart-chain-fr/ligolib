#import "types.mligo" "TYPES"
#import "errors.mligo" "ERRORS"

// --------------------------------------
//       CONFIG RELATED ASSERTIONS
// --------------------------------------

let assert_is_manager (p_sender : address)(p_manager : address) : unit =
  if (p_sender <> p_manager)
    then failwith ERRORS.not_manager

let assert_is_manager__or_signer (p_sender : address)(p_manager : address)(p_signer : address) : unit =
  if ((p_sender <> p_manager) && (p_sender <> p_signer) )
  then failwith ERRORS.not_manager_nor_signer

let assert_not_previous_manager (p_new_manager : address)(p_prev_manager : address) : unit =
  if (p_new_manager = p_prev_manager)
    then failwith ERRORS.same_previous_manager

let assert_not_previous_signer (p_new_signer : address)(p_prev_signer : address) : unit =
  if (p_new_signer = p_prev_signer)
    then failwith ERRORS.same_previous_signer

let assert_event_creation_not_paused (p_event_creation_paused : bool) : unit =
  if (p_event_creation_paused)
    then failwith ERRORS.event_creation_paused