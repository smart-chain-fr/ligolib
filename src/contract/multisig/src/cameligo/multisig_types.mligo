type max_duration_in_sec = nat
type fa12_transfer = address * (address * nat)
type operation_counter = nat

type operation_send = {
    target_fa12: address;
    target_to: address;
    token_amount: nat;
    timestamp: timestamp;
    approved_signers: address set;
    number_of_signer: nat;
    executed: bool;
}

type storage_multisig = {
    signers: address set;
    threshold: nat;
    operation_map: (nat, operation) big_map;
    operation_counter: nat;
}

type operation_params = {
    target_fa12: address;
    target_to: address;
    token_amount: nat;
}

type no_operation = operation list
type return = operation list * storage_multisig

type entrypoint = 
    | Create_operation of (operation_params)
    | Sign             of (operation_counter)