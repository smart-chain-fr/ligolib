#import "types.mligo" "TYPES"
#import "errors.mligo" "ERRORS"

// --------------------------------------
//       CONFIG RELATED ASSERTIONS
// --------------------------------------

let assert_is_manager (pSender : address)(pManager : address) : unit =
  if (pSender <> pManager)
    then failwith ERRORS.not_manager

let assert_is_manager__or_signer (pSender : address)(pManager : address)(pSigner : address) : unit =
  if ((pSender <> pManager) && (pSender <> pSigner) )
  then failwith ERRORS.not_manager_nor_signer

let assert_not_previous_manager (pNewManager : address)(pPrevManager : address) : unit =
  if (pNewManager = pPrevManager)
    then failwith ERRORS.same_previous_manager

let assert_not_previous_signer (pNewSigner : address)(pPrevSigner : address) : unit =
  if (pNewSigner = pPrevSigner)
    then failwith ERRORS.same_previous_signer

let assert_event_creation_not_paused (pEventCreationPaused : bool) : unit =
  if (pEventCreationPaused)
    then failwith ERRORS.event_creation_paused