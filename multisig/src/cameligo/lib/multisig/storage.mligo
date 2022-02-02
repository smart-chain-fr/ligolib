#import "parameter.mligo" "Parameter"
#import "errors.mligo" "Errors"

module Types = struct
    type proposal = 
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

    type t = 
    [@layout:comb]
    {
        proposal_counter: nat;
        proposal_map: (nat, proposal) big_map;
        signers: address set;
        threshold: nat;
    }
end

module Utils = struct
    [@inline] 
    let new_storage (signers: address set) (threshold: nat) : Types.t =
        {
            proposal_counter = 0n;
            proposal_map     = (Big_map.empty : (nat, Types.proposal) big_map);
            signers          = signers;
            threshold        = threshold;
        }

    [@inline]
    let create_proposal (params: Parameter.Types.proposal_params) : Types.proposal =
        { 
            target_fa12      = params.target_fa12;
            target_to        = params.target_to;
            token_amount     = params.token_amount;
            timestamp        = Tezos.now;
            approved_signers = Set.literal [Tezos.sender];
            number_of_signer = 1n;
            executed         = false;
        } 
    
    [@inline]
    let register_proposal (proposal: Types.proposal) (storage: Types.t) : Types.t =
        let proposal_counter = storage.proposal_counter + 1n in
        let proposal_map = Big_map.add proposal_counter proposal storage.proposal_map in
        { 
            storage with 
            proposal_map     = proposal_map; 
            proposal_counter = proposal_counter 
        }

    [@inline]
    let retrieve_proposal (proposal_number: Parameter.Types.proposal_number) (storage: Types.t) : Types.proposal = 
        match Big_map.find_opt proposal_number storage.proposal_map with
        | None -> failwith Errors.no_proposal_exist
        | Some(proposal) -> proposal

    [@inline]
    let add_signer_to_proposal (proposal: Types.proposal) (signer: address) (threshold: nat) : Types.proposal = 
        let approved_signers : address set = Set.add signer proposal.approved_signers in
        let executed = Set.size approved_signers >= threshold || proposal.executed in
        { 
            proposal with 
            approved_signers = approved_signers;
            number_of_signer = proposal.number_of_signer + 1n ;
            executed         = executed 
        }

    [@inline]
    let update_proposal (proposal_number: Parameter.Types.proposal_number) (proposal: Types.proposal) (storage: Types.t) : Types.t =
        let proposal_map = Map.update proposal_number (Some proposal) storage.proposal_map in
        { 
            storage with 
            proposal_map = proposal_map 
        }
end