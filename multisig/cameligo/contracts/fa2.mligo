
type atomic_trans = [@layout:comb] {
   to_      : address;
   token_id : nat;
}

type transfer_from = {
   from_ : address;
   tx    : atomic_trans list
}
type transfer = transfer_from list

module Types = struct
    type proposal = 
    [@layout:comb]
    {
        approved_signers: address set;
        executed: bool;
        number_of_signer: nat;
        target_fa2: address;
        transfers: transfer;
        timestamp: timestamp;
    }

    type t = 
    [@layout:comb]
    {
        proposal_counter: nat;
        proposal_map    : (nat, proposal) big_map;
        signers         : address set;
        threshold       : nat;
    }
end

let send (transfers : transfer) (target_fa2_address : address) : operation = 
    let fa2_contract_opt : transfer contract option = Tezos.get_entrypoint_opt "%transfer" target_fa2_address in
    match fa2_contract_opt with
    | Some contr -> Tezos.transaction (transfers) 0mutez contr
    | None -> (failwith "Cannot connect to the target transfer token entrypoint" : operation)

let perform_operations (proposal: Types.proposal) : operation list =
    if proposal.executed
    then [ send proposal.transfers proposal.target_fa2 ]
    else ([] : operation list)