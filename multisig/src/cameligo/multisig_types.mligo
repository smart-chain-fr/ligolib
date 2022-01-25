#import "fa2.mligo" "FA2"

type proposal = {
    approved_signers: address set;
    executed: bool;
    number_of_signer: nat;
    target_fa2: address;
    transfers: FA2.transfer;
    timestamp: timestamp;
}

type storage_multisig = {
    proposal_counter: nat;
    proposal_map: (nat, proposal) big_map;
    signers: address set;
    threshold: nat;
}

type proposal_params = {
    target_fa2: address;
    transfers: FA2.transfer;
}

type no_operation = operation list
type return = operation list * storage_multisig
