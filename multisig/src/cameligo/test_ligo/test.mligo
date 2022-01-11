#include "../multisig.mligo"

type storage_multisig_type = {
    proposal_counter: nat;
    proposal_map: (nat, proposal) big_map;
    signers: address set;
    threshold: nat;
}


// Main acces point
let test_initial_storage =

    // ========================
    // DEPLOY MULTISIG CONTRACT
    // ========================

    // Create the storage function to translate in michelson
    let tester_storage (x : storage_multisig_type) = x in
    // Prepare data for initial storage
    let empty_bigmap : (nat, proposal) big_map = Big_map.empty in 
    let address_1 : address = ( "tz1hA7UiKADZQbH8doJDiFY2bacWk8yAaU9i" : address) in
    let address_2 : address = ( "tz1UePZUsdbw8RpSvdSPpixBLVj8t6LQPLoz" : address) in
    let address_3 : address = ( "tz1RyejUffjfnHzWoRp1vYyZwGnfPuHsD5F5" : address) in
    let address_4 : address = ( "tz1QocWoPSz4syNWHrKroXhMPi1iZmbfcNLU" : address) in
    // Create the initial storage with specific values
    let initial_storage_multisig : storage_multisig_type = {
        proposal_counter = 0n;
        proposal_map = empty_bigmap;
        signers = (Set.add address_1 (Set.add address_2 (Set.add address_3 (Set.add address_4 (Set.empty : address set)))));
        threshold = 3n;
    } in
    // Primitive storage en michelson that runs a function on an input, translating both (function and input) to Michelson
    let tester_main = Test.run tester_storage initial_storage_multisig in
    // Get the contract path
    let contract_path_multisig = "src/cameligo/multisig.mligo" in
    // Originate an address, a code and a counter from a path to the contract file, an entrypoint, a list of views, an initial storage and an initial balance
    let (address_multisig, code_multisig, _) : (address * michelson_program * int) = Test.originate_from_file contract_path_multisig "multisigMain" (["superview"] : string list) tester_main 0tez in
    // Get the real storage from an address
    let storage_multisig = Test.get_storage_of_address address_multisig in
    // Cast an address to a typed address
    let address_multisig_typed = (Test.cast_address address_multisig : (entrypoint_multisig, storage_multisig_type) typed_address) in
    // Cast a typed address to contract
    let contract_multisig = Test.to_contract address_multisig_typed in
    // Get the contract storage
    let storage_multisig = Test.get_storage address_multisig_typed in
    // Assert that the storage is correct
    let _check_counter   = assert (storage_multisig.proposal_counter = initial_storage_multisig.proposal_counter ) in
    let _check_proposal  = assert (storage_multisig.proposal_map = initial_storage_multisig.proposal_map ) in
    let _check_signers   = assert (storage_multisig.signers = initial_storage_multisig.signers ) in
    let _check_threshold = assert (storage_multisig.threshold = initial_storage_multisig.threshold ) in
    ()