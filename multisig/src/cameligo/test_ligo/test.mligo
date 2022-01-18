#import "../multisig.mligo" "MS"
#import "../multisig_types.mligo" "T"
#import "../fa12.mligo" "FA"

// ===== SIGNERS =====
let _create_accounts = Test.reset_state 6n ([] : tez list)
let alice : address = Test.nth_bootstrap_account 0
let bob : address = Test.nth_bootstrap_account 1
let charly : address = Test.nth_bootstrap_account 2
let delta : address = Test.nth_bootstrap_account 3
let echo : address = Test.nth_bootstrap_account 4
let unknown = Test.nth_bootstrap_account 5

// ===== FAILWITH HELPER =======
let assert_string_failure (res : test_exec_result) (expected : string) : unit =
    let expected = Test.eval expected in
    match res with
    | Fail (Rejected (actual,_)) -> assert (Test.michelson_equal actual expected)
    | Fail (Other) -> failwith "Contract have failed"
    | Success -> failwith "Test should have failed"

// ========== DEPLOY MULTISIG CONTRACT HELPER ============
let originate_multisig (initial_storage_multisig : T.storage_multisig) :
    T.storage_multisig * address * (MS.entrypoint_multisig, T.storage_multisig) typed_address * michelson_program =
    // Create the storage function to translate in michelson
    let tester_storage (x : T.storage_multisig) = x in
    // Primitive storage en michelson that runs a function on an input, translating both (function and input) to Michelson
    let tester_main = Test.run tester_storage initial_storage_multisig in
    // Get the contract path
    let contract_path_multisig = "src/cameligo/multisig.mligo" in
    // Originate an address, a code and a counter from a path to the contract file, an entrypoint, a list of views, an initial storage and an initial balance
    let (address_multisig, code_multisig, _) : (address * michelson_program * int) = Test.originate_from_file contract_path_multisig "multisigMain" (["superview"] : string list) tester_main 0tez in
    // Cast an address to a typed address
    let address_multisig_typed : (MS.entrypoint_multisig, T.storage_multisig) typed_address = (Test.cast_address address_multisig : (MS.entrypoint_multisig, T.storage_multisig) typed_address) in
    (Test.get_storage address_multisig_typed, address_multisig, address_multisig_typed, code_multisig)

// ========== DEPLOY FA12 CONTRACT HELPER ============
let originate_fa12 (initial_storage_multisig : FA.storage) :
    FA.storage * address * (FA.parameter, FA.storage) typed_address * michelson_program =
    // Create the storage function to translate in michelson
    let tester_storage (x : FA.storage) = x in
    // Primitive storage en michelson that runs a function on an input, translating both (function and input) to Michelson
    let tester_main = Test.run tester_storage initial_storage_multisig in
    // Get the contract path
    let contract_path_fa12 = "src/cameligo/fa12.mligo" in
    // Originate an address, a code and a counter from a path to the contract file, an entrypoint, a list of views, an initial storage and an initial balance
    let (address_fa12, code_fa12, _) : (address * michelson_program * int) = Test.originate_from_file contract_path_fa12 "main" (["superview"] : string list) tester_main 0tez in
    // Cast an address to a typed address
    let address_fa12_typed : (FA.parameter, FA.storage) typed_address = (Test.cast_address address_fa12 : (FA.parameter, FA.storage) typed_address) in
    // Get the contract storage
    (Test.get_storage address_fa12_typed, address_fa12, address_fa12_typed, code_fa12)

// ===================================
// ========== BEGIN TESTS ============
// ===================================
let test_originate_contract_with_correct_storage_should_work =
    // Prepare data for initial storage
    let empty_bigmap : (nat, MS.proposal) big_map = Big_map.empty in 
    let address_1 : address = alice in
    let address_2 : address = bob in
    let address_3 : address = charly in
    let address_4 : address = delta in
    // Create the initial multisig storage with specific values
    let initial_storage_multisig : T.storage_multisig = {
        proposal_counter = 0n;
        proposal_map = empty_bigmap;
        signers = (Set.add address_1 (Set.add address_2 (Set.add address_3 (Set.add address_4 (Set.empty : address set)))));
        threshold = 3n;
    } in
    // Originate contract
    let (storage_multi, address_multi, typed_address_multi, program_multi) :
        ( T.storage_multisig * address * (MS.entrypoint_multisig, T.storage_multisig) typed_address * michelson_program) = 
        originate_multisig initial_storage_multisig in
    // Assert that the storage is correct
    let _check_counter   = assert (storage_multi.proposal_counter = initial_storage_multisig.proposal_counter ) in
    let _check_proposal  = assert (storage_multi.proposal_map = initial_storage_multisig.proposal_map ) in
    let _check_signers   = assert (storage_multi.signers = initial_storage_multisig.signers ) in
    let _check_threshold = assert (storage_multi.threshold = initial_storage_multisig.threshold ) in
    "✓"

let test_create_multisig_proposal_without_being_signer_should_fail =
    // Prepare data for initial storage
    let empty_bigmap : (nat, MS.proposal) big_map = Big_map.empty in 
    let address_1 : address = alice in
    let address_2 : address = bob in
    let address_3 : address = charly in
    // Create the initial multisig storage with specific values
    let initial_storage_multisig : T.storage_multisig = {
        proposal_counter = 0n;
        proposal_map = empty_bigmap;
        signers = (Set.add address_1 (Set.add address_2 (Set.add address_3 (Set.empty : address set))));
        threshold = 2n;
    } in
    // Originate contract multisig and cast a typed address to get the contract artefact
    let (storage_multi, address_multi, typed_address_multi, program_multi) :
        ( T.storage_multisig * address * (MS.entrypoint_multisig, T.storage_multisig) typed_address * michelson_program) = 
        originate_multisig initial_storage_multisig in
    let contract_multisig = Test.to_contract typed_address_multi in
    // Create the initial fa12 storage
    let empty_bigmap : (FA.allowance_key, nat) big_map = Big_map.empty in 
    let initial_storage_fa12 : FA.storage = {
        tokens = Big_map.add alice 1000n Big_map.empty;
        allowances = empty_bigmap;
        total_supply = 1000n;
    } in
    // Originate contract fa12 and cast a typed address to get the contract artefact
    let (storage_fa, address_fa, typed_address_fa, program_fa) :
        FA.storage * address * (FA.parameter, FA.storage) typed_address * michelson_program = 
        originate_fa12 initial_storage_fa12 in
    let contract_fa12 = Test.to_contract typed_address_fa in
    // Create a new proposal
    let new_proposal : T.proposal_params = {
        target_fa12 = address_fa;
        target_to = echo;
        token_amount = 100n;
    } in
    // Send a new proposal without being a signer should fail
    let () = Test.set_source echo in
    let fail_tx : test_exec_result = Test.transfer_to_contract contract_multisig (Create_proposal(new_proposal)) 0mutez in
    let () = assert_string_failure (fail_tx: test_exec_result) ("Only one of the contract signer can create an proposal":string) in
    "✓"

let test_create_multisig_proposal_with_a_signer_should_work =
    // Prepare data for initial storage
    let empty_bigmap : (nat, MS.proposal) big_map = Big_map.empty in 
    let address_1 : address = alice in
    let address_2 : address = bob in
    let address_3 : address = charly in
    // Create the initial multisig storage with specific values
    let initial_storage_multisig : T.storage_multisig = {
        proposal_counter = 0n;
        proposal_map = empty_bigmap;
        signers = (Set.add address_1 (Set.add address_2 (Set.add address_3 (Set.empty : address set))));
        threshold = 2n;
    } in
    // Originate contract multisig and cast a typed address to get the contract artefact
    let (storage_multi, address_multi, typed_address_multi, program_multi) :
        ( T.storage_multisig * address * (MS.entrypoint_multisig, T.storage_multisig) typed_address * michelson_program) = 
        originate_multisig initial_storage_multisig in
    let contract_multisig = Test.to_contract typed_address_multi in
    // Create the initial fa12 storage
    let empty_bigmap : (FA.allowance_key, nat) big_map = Big_map.empty in 
    let initial_storage_fa12 : FA.storage = {
        tokens = Big_map.add alice 1000n Big_map.empty;
        allowances = empty_bigmap;
        total_supply = 1000n;
    } in
    // Originate contract fa12 and cast a typed address to get the contract artefact
    let (storage_fa, address_fa, typed_address_fa, program_fa) :
        FA.storage * address * (FA.parameter, FA.storage) typed_address * michelson_program = 
        originate_fa12 initial_storage_fa12 in
    let contract_fa12 = Test.to_contract typed_address_fa in
    // Create a new proposal
    let new_proposal : T.proposal_params = {
        target_fa12 = address_fa;
        target_to = echo;
        token_amount = 100n;
    } in
    // Send a new proposal with a signer should work
    let () = Test.set_source alice in
    let tx : test_exec_result = Test.transfer_to_contract contract_multisig (Create_proposal(new_proposal)) 0mutez in
    let new_storage : MS.storage_multisig = Test.get_storage typed_address_multi in
    let new_proposal : MS.proposal = match Map.find_opt 1n new_storage.proposal_map with
        Some value -> value
      | None -> failwith "f"
    in
    let () = assert ( new_proposal.number_of_signer = 1n) in

    "✓"