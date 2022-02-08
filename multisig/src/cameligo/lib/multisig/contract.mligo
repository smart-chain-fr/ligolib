#import "errors.mligo" "Errors"
#import "conditions.mligo" "Conditions"
#import "contracts/fa12.mligo" "FA12"

(* Proposal creation *)
 
module Proposal = struct 
    type t = 
    [@layout:comb]
    {
        approved_signers: address set;
        executed: bool;
        number_of_signer: nat;
        target_fa12: address;
        target_to: address;
        timestamp: timestamp;
        token_amount: nat;
    }

    [@inline]
    let create (target_fa12: address) (target_to: address) (token_amount: nat) : t =
        { 
            target_fa12      = target_fa12;
            target_to        = target_to;
            token_amount     = token_amount;
            timestamp        = Tezos.now;
            approved_signers = Set.literal [Tezos.sender];
            number_of_signer = 1n;
            executed         = false;
        } 

    [@inline]
    let add_signer (proposal: t) (signer: address) (threshold: nat) : t = 
        let approved_signers : address set = Set.add signer proposal.approved_signers in
        let executed = Set.size approved_signers >= threshold || proposal.executed in
        { 
            proposal with 
            approved_signers = approved_signers;
            number_of_signer = proposal.number_of_signer + 1n ;
            executed         = executed 
        }
end

module Storage = struct
    type t = 
    [@layout:comb]
    {
        proposal_counter: nat;
        proposal_map: (nat, Proposal.t) big_map;
        signers: address set;
        threshold: nat;
    }

    [@inline]
    let register_proposal (storage: t) (proposal: Proposal.t) : t =
        let proposal_counter = storage.proposal_counter + 1n in
        let proposal_map = Big_map.add proposal_counter proposal storage.proposal_map in
        { 
            storage with 
            proposal_map     = proposal_map; 
            proposal_counter = proposal_counter 
        }

    [@inline]
    let retrieve_proposal (storage: t) (proposal_number: nat) : Proposal.t = 
        match Big_map.find_opt proposal_number storage.proposal_map with
        | None -> failwith Errors.no_proposal_exist
        | Some(proposal) -> proposal

    [@inline]
    let update_proposal (storage: t) (proposal_number: nat) (proposal: Proposal.t) : t =
        let proposal_map = Map.update proposal_number (Some proposal) storage.proposal_map in
        { 
            storage with 
            proposal_map = proposal_map 
        }
end

type proposal_params = 
    [@layout:comb]
    {
        target_fa12: address;
        target_to: address;
        token_amount: nat;
    }

let create_proposal (params : proposal_params) (storage : Storage.t) : operation list * Storage.t = 
    let () = Conditions.only_signer storage.signers in
    let () = Conditions.amount_must_be_zero_tez Tezos.amount in 
    let proposal = Proposal.create params.target_fa12 params.target_to params.token_amount in

    let storage = Storage.register_proposal storage proposal in

    ([] : operation list), storage

(* Proposal signature *)

type proposal_number = nat

let sign_proposal (proposal_number : proposal_number) (storage : Storage.t) : operation list * Storage.t =
    let () = Conditions.only_signer storage.signers in
    let proposal = Storage.retrieve_proposal storage proposal_number in
    let () = Conditions.not_yet_signer proposal.approved_signers in

    let proposal = Proposal.add_signer proposal Tezos.sender storage.threshold in
    let storage = Storage.update_proposal storage proposal_number proposal in

    let operations = FA12.perform_operations proposal.executed proposal.token_amount proposal.target_to proposal.target_fa12 in

    operations, storage

// ===============================================================================================

type parameter = 
    | Create_proposal of (proposal_params)
    | Sign_proposal of (proposal_number)    

let main (action, storage : parameter * Storage.t) : operation list * Storage.t =
    match action with
    | Create_proposal(proposal_params) -> 
        create_proposal proposal_params storage 
    | Sign_proposal(proposal_number) -> 
        sign_proposal proposal_number storage