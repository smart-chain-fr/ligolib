#import "types.mligo" "TYPES"
#import "errors.mligo" "ERRORS"

// --------------------------------------
//       CONFIG RELATED ASSERTIONS
// --------------------------------------

let assertIsManager (pSender : address)(pManager : address) : unit =
  if (pSender <> pManager)
    then failwith ERRORS.not_manager

let assertIsManagerOrSigner (pSender : address)(pManager : address)(pSigner : address) : unit =
  if ((pSender <> pManager) && (pSender <> pSigner) )
  then failwith ERRORS.not_manager_nor_signer

let assertNotPreviousManager (pNewManager : address)(pPrevManager : address) : unit =
  if (pNewManager = pPrevManager)
    then failwith ERRORS.same_previous_manager

let assertNotPreviousSigner (pNewSigner : address)(pPrevSigner : address) : unit =
  if (pNewSigner = pPrevSigner)
    then failwith ERRORS.same_previous_signer

let assertEventCreationNotPaused (pEventCreationPaused : bool) : unit =
  if (pEventCreationPaused)
    then failwith ERRORS.event_creation_paused