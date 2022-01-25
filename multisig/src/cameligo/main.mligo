// ----------
// -- MAIN --
// ----------
#import "multisig.mligo" "M"
type entrypoint_multisig = Create_proposal of M.T.proposal_params | Sign of nat

let main(action, store : entrypoint_multisig * M.T.storage_multisig) : M.T.return_multisig =
    let ret: M.T.return_multisig = match action with
    Create_proposal(p)   -> M.create_proposal     p store
    | Sign(p)            -> M.sign                p store
    in 
    ret