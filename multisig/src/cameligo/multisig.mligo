#include "multisig_types.mligo"
#include "multisig_error.mligo"

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

let create_proposal (storage : storage_multisig) (params : proposal_params) : return = // Amount can be zero
    let _check_is_signer : unit  = assert_with_error (Set.mem Tezos.sender storage.signers) only_signer in
    let _check_if_no_tez : unit = assert_with_error (Tezos.amount = 0tez) amount_must_be_zero_tez in
    
    let new_proposal_counter : nat = storage.proposal_counter + 1n in
    let new_proposal : proposal = { target_fa12  = params.target_fa12;
                                           target_to    = params.target_to;
                                           token_amount = params.token_amount;
                                           timestamp = Tezos.now;
                                           approved_signers =Set.literal [Tezos.sender];
                                           number_of_signer = 1n;
                                           executed = false; } in
    let new_proposal_map : (nat, proposal) big_map = Big_map.add new_proposal_counter new_proposal storage.proposal_map in
    let final_storage = { storage with proposal_map     = new_proposal_map;
                                        proposal_counter = new_proposal_counter } in
    (no_operation, final_storage)

let sign (storage : storage_multisig) (proposal_number : nat) : return =
    let _check_is_signer : unit  = assert_with_error (Set.mem Tezos.sender storage.signers) only_signer in

    let target_proposal : proposal = match Big_map.find_opt (proposal_number : nat) storage.proposal_map with
        | None -> (failwith no_proposal_exist : proposal)
        | Some(proposal) -> proposal
    in

    let _check_has_already_signed : unit  = assert_with_error (Set.mem (Tezos.sender : address) target_proposal.approved_signers) has_already_signed in

    let updated_approved_signers : address set = Set.add Tezos.sender target_proposal.approved_signers in
     
    if Set.size updated_approved_signers >= storage.threshold then
        let updated_proposal : proposal = { target_proposal with approved_signers = updated_approved_signers;
                                                                number_of_signer = target_proposal.number_of_signer + 1n ;
                                                                executed         = true } in
        let updated_proposal_map : (nat, proposal) big_map = Map.update (proposal_number : nat) (Some(updated_proposal : proposal)) (storage.proposal_map : (nat, proposal) big_map) in
        let final_operation : operation = sendFA12 target_proposal.token_amount target_proposal.target_to target_proposal.target_fa12 in
        let final_storage : storage_multisig = { storage with proposal_map = updated_proposal_map } in
        ([final_operation], final_storage)
    else
        let updated_proposal : proposal = { target_proposal with approved_signers = updated_approved_signers;
                                                                number_of_signer = target_proposal.number_of_signer + 1n } in
        let updated_proposal_map : (nat, proposal) big_map = Map.update (proposal_number : nat) (Some(updated_proposal) : proposal option) (storage.proposal_map : (nat, proposal) big_map) in
        let final_storage : storage_multisig = { storage with proposal_map = updated_proposal_map } in
        (no_operation, final_storage)    



// ----------
// -- MAIN --
// ----------

let multisigMain (action, storage : entrypoint * storage_multisig) : return =
    match action with
    | Create_proposal(proposal_params) -> create_proposal     storage proposal_params
    | Sign(proposal_number)            -> sign                storage proposal_number
