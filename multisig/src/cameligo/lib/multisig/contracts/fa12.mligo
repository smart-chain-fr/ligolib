#import "../errors.mligo" "Errors"

type t = address * (address * nat)

// TODO(check the semantic of this function)
let send (token_amount : nat) (target_to : address) (target_fa12 : address) : operation = 
    let contract_opt : t contract option = Tezos.get_entrypoint_opt "%transfer" target_fa12 in
    match contract_opt with
    | Some transfer ->     
        let transfer_param = target_fa12, (target_to , token_amount) in 
        Tezos.transaction (transfer_param) 0mutez transfer
    | None -> 
        failwith Errors.unknown_reward_token_entrypoint

[@inline]
let perform_operations (executed: bool) (token_amount : nat) (target_to : address) (target_fa12 : address) : operation list =
    if executed
    then [ send token_amount target_to target_fa12 ]
    else []