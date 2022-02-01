type fa12_transfer = address * (address * nat)

type max_duration_in_sec = nat

type proposal_number = nat

module Storage = struct
    type proposal = {
        approved_signers: address set;
        executed: bool;
        number_of_signer: nat;
        target_fa12: address;
        target_to: address;
    //    target_from:
        timestamp: timestamp;
        token_amount: nat;
    }

    type multisig = {
        proposal_counter: nat;
        proposal_map: (nat, proposal) big_map;
        signers: address set;
        threshold: nat;
    }
end

type proposal_params = {
    target_fa12: address;
    target_to: address;
    token_amount: nat;
}

type no_operation = operation list
type return = operation list * storage_multisig
