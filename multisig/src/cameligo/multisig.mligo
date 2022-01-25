#import "multisig_types.mligo" "T"
#import "multisig_error.mligo" "E"

// -----------------
// --  CONSTANTS  --
// -----------------
let no_operation : operation list = []

// -----------------
// --  INTERNALS  --
// -----------------

let sendFA2 (transfer : T.FA2.transfer) (target_fa2_address : address) : operation = 
    let fa2_contract_opt : T.FA2.transfer contract option = Tezos.get_entrypoint_opt "%transfer" target_fa2_address in
    let transfer_fa2 : T.FA2.transfer contract = match fa2_contract_opt with
    | Some c -> c
    | None -> (failwith E.unknown_contract_entrypoint: T.FA2.transfer contract)
    in
    let op : operation = Tezos.transaction (transfer) 0mutez transfer_fa2 in
    op

// ------------------
// -- ENTRY POINTS --
// ------------------

let create_proposal(params : T.proposal_params)  (storage : T.storage_multisig) : T.return_multisig = // Amount can be zero
    let _check_is_signer : unit  = assert_with_error (Set.mem Tezos.sender storage.signers) E.only_signer in
    let _check_if_no_tez : unit = assert_with_error (Tezos.amount = 0tez) E.amount_must_be_zero_tez in
    
    let new_proposal : T.proposal = { target_fa2  = params.target_fa2;
                                           transfers = params.transfers;
                                           timestamp = Tezos.now;
                                           approved_signers =Set.literal [Tezos.sender];
                                           number_of_signers = 1n;
                                           executed = false; } in
    let new_proposal_map : (nat, T.proposal) big_map = Big_map.add  storage.proposal_counter new_proposal storage.proposal_map in
    let final_storage = { storage with proposal_map     = new_proposal_map;
                                        proposal_counter = storage.proposal_counter + 1n } in
    (no_operation, final_storage)

let sign (proposal_number : nat) (storage : T.storage_multisig) : T.return_multisig =
    let _check_is_signer : unit  = assert_with_error (Set.mem Tezos.sender storage.signers) E.only_signer in

    let target_proposal : T.proposal = match Big_map.find_opt (proposal_number : nat) storage.proposal_map with
        | None -> (failwith E.no_proposal_exist : T.proposal)
        | Some(proposal) -> proposal
    in

    let _check_has_already_signed : unit  = assert_with_error (not (Set.mem (Tezos.sender : address) target_proposal.approved_signers)) E.has_already_signed in

    let updated_approved_signers : address set = Set.add Tezos.sender target_proposal.approved_signers in

    if Set.size updated_approved_signers >= storage.threshold then
        let updated_proposal : T.proposal = { target_proposal with approved_signers = updated_approved_signers;
                                                                number_of_signers = target_proposal.number_of_signers + 1n ;
                                                                executed         = true } in
        let updated_proposal_map : (nat, T.proposal) big_map = Map.update (proposal_number : nat) (Some(updated_proposal : T.proposal)) (storage.proposal_map : (nat, T.proposal) big_map) in
        let final_operation : operation = sendFA2 target_proposal.transfers target_proposal.target_fa2 in
        let final_storage : T.storage_multisig = { storage with proposal_map = updated_proposal_map } in
        ([final_operation], final_storage)
    else
        let updated_proposal : T.proposal = { target_proposal with approved_signers = updated_approved_signers;
                                                                number_of_signers = target_proposal.number_of_signers + 1n } in
        let updated_proposal_map : (nat, T.proposal) big_map = Map.update (proposal_number : nat) (Some(updated_proposal) : T.proposal option) (storage.proposal_map : (nat, T.proposal) big_map) in
        let final_storage : T.storage_multisig = { storage with proposal_map = updated_proposal_map } in
        (no_operation, final_storage)    




