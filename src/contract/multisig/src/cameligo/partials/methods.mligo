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

let sendFA12 (token_amount : nat) (target_to : address) (target_fa12_address : address) : operation = 
    let fa12_contract_opt : fa12_transfer contract option = Tezos.get_entrypoint_opt "%transfer" target_fa12_address in
    let transfer_fa12 : fa12_transfer contract = match fa12_contract_opt with
    | Some c -> c
    | None -> (failwith unknown_reward_token_entrypoint: fa12_transfer contract)
    in
    let transfer_param : fa12_transfer = target_fa12_address, (target_to , token_amount) in 
    let op : operation = Tezos.transaction (transfer_param) 0mutez transfer_fa12 in
    op

// ------------------
// -- ENTRY POINTS --
// ------------------

let create_operation (storage : storage_multisig) (params : operation_params) : return = // Amount can be zero
    let _check_is_signer : unit  = assert_with_error (Set.mem Tezos.sender storage.signers) only_signer in
    let _check_if_no_tez : unit = assert_with_error (Tezos.amount = 0tez) amount_must_be_zero_tez in
    
    let new_operation_counter : nat = storage.operation_counter + 1n
    let new_operation : operation = {
        target_fa12: params.target_fa12;
        target_to: params.target_to;
        token_amount: params.token_amount;
        timestamp: Tezos.now;
        approved_signers: Set.literal [Tezos.sender];
        executed: false
    }
    let new_operation_map : (nat, operation) big_map = Big_map.add new_operation_counter new_operation storage.operation_map

    let final_storage = { storage with operation_map     = new_operation_map ;
                                       operation_counter = new_operation_counter } in
    (no_operation, final_storage)

let sign (storage : storage_multisig) (operation_counter : nat) : return =
    let _check_is_signer : unit  = assert_with_error (Set.mem Tezos.sender storage.signers) only_signer in

    let target_operation : operation = match storage.operation_map(operation_counter) with
        | None -> (failwith no_operation_exist : operation)
        | Some(operation) -> operation
    in

    let _check_has_already_signed : unit  = assert_with_error (Set.mem Tezos.sender operation.approved_signers) has_already_signed in

    let updated_approved_signers : address set = Set.add Tezos.sender target_operation.approved_signers in

    let updated_operation : operation = {
        target_operation with
        approved_signers: updated_approved_signers ;
    }

    