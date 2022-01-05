#include "types.mligo"
#include "error.mligo"

// -----------------
// --  CONSTANTS  --
// -----------------
let max_duration_in_sec : nat  = 6048000n // 10 weeks
let no_operation : operation list = []
let empty_nat_list : nat list = []


// -----------------
// --  INTERNALS  --
// -----------------

let sendFA12 (token_amount : nat) (target_to : address) (target_fa12 : address) : operation = 
    //TODO 
    match reward_fa2_token_id_opt with
    | None -> //use FA12
        let fa12_contract_opt : fa12_transfer contract option = Tezos.get_entrypoint_opt "%transfer" reward_token_address in
        let transfer_fa12 : fa12_transfer contract = match fa12_contract_opt with
        | Some c -> c
        | None -> (failwith unknown_reward_token_entrypoint: fa12_transfer contract)
        in
        let transfer_param : fa12_transfer = reward_reserve_address, (user_address , token_amount) in 
        let op : operation = Tezos.transaction (transfer_param) 0mutez transfer_fa12 in
        op
    | Some(reward_fa2_token_id) -> // use FA2 
        let fa2_contract_opt : fa2_transfer contract option = Tezos.get_entrypoint_opt "%transfer" reward_token_address in
        let transfer_fa2 : fa2_transfer contract = match fa2_contract_opt with
        | Some c -> c
        | None -> (failwith unknown_reward_token_entrypoint: fa2_transfer contract)
        in
        let transfer_fa2_param : fa2_transfer = reward_reserve_address, (user_address, reward_fa2_token_id, token_amount) in 
        let op_fa2 : operation = Tezos.transaction (transfer_fa2_param) 0mutez transfer_fa2 in
        op_fa2

// ------------------
// -- ENTRY POINTS --
// ------------------

let create_operation (storage : storage_multisig) (params : operation_params) : return = // PEDAGO : amount can be zero
    let check_is_signer : unit  = assert_with_error (Set.mem Tezos.sender storage_multisig.signers) only_signer in
    let _check_if_no_tez : unit = assert_with_error (Tezos.amount = 0tez) amount_must_be_zero_tez in
    

