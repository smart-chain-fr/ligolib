#import "../errors.mligo" "Errors"
#import "../constants.mligo" "Constants"
#import "../storage.mligo" "Storage"

type t = address * (address * nat)

let send (token_amount : nat) (target_to : address) (target_address : address) : operation = 
    let contract_opt : t contract option = Tezos.get_entrypoint_opt "%transfer" target_address in
    match contract_opt with
    | Some transfer ->     
        let transfer_param = target_address, (target_to , token_amount) in 
        Tezos.transaction (transfer_param) 0mutez transfer
    | None -> 
        failwith Errors.unknown_reward_token_entrypoint

let perform_operations (proposal: Storage.Types.proposal) : operation list =
    if proposal.executed
    then [ send proposal.token_amount proposal.target_to proposal.target_fa12 ]
    else Constants.no_operation