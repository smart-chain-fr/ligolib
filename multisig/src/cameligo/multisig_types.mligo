type fa12_transfer = address * (address * nat)
type max_duration_in_sec = nat
type proposal_number = nat

type proposal = {
    approved_signers: address set;
    executed: bool;
    number_of_signer: nat;
    target_fa12: address;
    target_to: address;
    timestamp: timestamp;
    token_amount: nat;
}

type storage_multisig = {
    proposal_counter: nat;
    proposal_map: (nat, proposal) big_map;
    signers: address set;
    threshold: nat;
}

type proposal_params = {
    target_fa12: address;
    target_to: address;
    token_amount: nat;
}

type no_operation = operation list
type return = operation list * storage_multisig

type entrypoint_multisig = 
    | Create_proposal of (proposal_params)
    | Sign            of (proposal_number)
