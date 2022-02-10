#import "../lib/fa12/parameter.mligo" "FA12_Parameter"
#import "../lib/fa12/storage.mligo" "FA12_Storage"
#import "../lib/fa12/contract.mligo" "FA12"

#import "../lib/multisig/parameter.mligo" "Parameter"
#import "../lib/multisig/storage.mligo" "Storage"
#import "../lib/multisig/contract.mligo" "Multisign"

// ===== SIGNERS =====
let _create_accounts = Test.reset_state 6n ([] : tez list)
let alice   = Test.nth_bootstrap_account 0
let bob     = Test.nth_bootstrap_account 1
let charly  = Test.nth_bootstrap_account 2
let delta   = Test.nth_bootstrap_account 3
let echo    = Test.nth_bootstrap_account 4
let unknown = Test.nth_bootstrap_account 5

// ===== FAILWITH HELPER =======
let assert_string_failure (res : test_exec_result) (expected : string) : unit =
    let expected = Test.eval expected in
    match res with
    | Fail (Rejected (actual,_)) -> assert (Test.michelson_equal actual expected)
    | Fail (Other) -> failwith "Contract have failed"
    | Success -> failwith "Test should have failed"

// ========== DEPLOY CONTRACT HELPER ============
let originate (type s p) (storage: s) (main: (p * s) -> operation list * s) : (p,s) typed_address * p contract =
    let (typed_address, _, _) = Test.originate main storage 0tez in
    typed_address, Test.to_contract typed_address

// ===================================
// ========== BEGIN TESTS ============
// ===================================
let test_originate_contract_with_correct_storage_should_work =
    // Prepare data for initial storage
    let empty_bigmap : (nat, Storage.Types.proposal) big_map = Big_map.empty in 
    let initial_storage_multisig : Storage.Types.t = {
        proposal_counter = 0n;
        proposal_map = empty_bigmap;
        signers = (Set.add alice (Set.add bob (Set.add charly (Set.add delta (Set.empty : address set)))));
        threshold = 3n;
    } in
    // Originate contract
    let (typed_address_multi,_) = originate initial_storage_multisig Multisign.main in
    let storage_multi : Storage.Types.t = Test.get_storage typed_address_multi in
    // Assert that the storage is correct
    let () = assert (storage_multi.proposal_counter = initial_storage_multisig.proposal_counter ) in
    let () = assert (storage_multi.proposal_map = initial_storage_multisig.proposal_map ) in
    let () = assert (storage_multi.signers = initial_storage_multisig.signers ) in
    let () = assert (storage_multi.threshold = initial_storage_multisig.threshold ) in
    "✓"

let test_create_multisig_proposal_without_being_signer_should_fail =
    // Prepare data for initial storage
    let empty_bigmap : (nat, Storage.Types.proposal) big_map = Big_map.empty in 
    let initial_storage_multisig : Storage.Types.t = {
        proposal_counter = 0n;
        proposal_map = empty_bigmap;
        signers = (Set.add alice (Set.add bob (Set.add charly (Set.add delta (Set.empty : address set)))));
        threshold = 3n;
    } in
    // Originate contract multisig 
    let (_,contract_multisig) = originate initial_storage_multisig Multisign.main in
    // Create the initial fa12 storage
    let empty_bigmap : (FA12_Parameter.Types.allowance_key, nat) big_map = Big_map.empty in 
    let initial_storage_fa12 = {
        tokens = Big_map.add alice 1000n Big_map.empty;
        allowances = empty_bigmap;
        total_supply = 1000n;
    } in
    // Originate contract fa12 
    let (typed_address_fa12,contract_fa12) = originate initial_storage_fa12 FA12.main in
    // Create a new proposal
    let new_proposal : Parameter.Types.proposal_params = {
        target_fa12 = Tezos.address contract_fa12;
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
    let empty_bigmap : (nat, Storage.Types.proposal) big_map = Big_map.empty in 
    // Create the initial multisig storage with specific values
    let initial_storage_multisig : Storage.Types.t = {
        proposal_counter = 0n;
        proposal_map = empty_bigmap;
        signers = (Set.add alice (Set.add bob (Set.add charly (Set.empty : address set))));
        threshold = 2n;
    } in
    // Originate contract multisig and cast a typed address to get the contract artefact
    let (typed_address_multi,contract_multisig) = originate initial_storage_multisig Multisign.main in
    // Create the initial fa12 storage
    let empty_bigmap : (FA12_Parameter.Types.allowance_key, nat) big_map = Big_map.empty in 
    let initial_storage_fa12 : FA12_Storage.Types.t = {
        tokens = Big_map.add alice 1000n Big_map.empty;
        allowances = empty_bigmap;
        total_supply = 1000n;
    } in
    // Originate contract fa12 and cast a typed address to get the contract artefact
    let (typed_address_fa,contract_fa12) = originate initial_storage_fa12 FA12.main in
    // Create a new proposal
    let new_proposal : Parameter.Types.proposal_params = {
        target_fa12 = Tezos.address contract_fa12;
        target_to = echo;
        token_amount = 100n;
    } in
    // Send a new proposal with a signer should work
    let () = Test.set_source alice in
    let tx : test_exec_result = Test.transfer_to_contract contract_multisig (Create_proposal(new_proposal)) 0mutez in
    let () = Test.log(tx) in
    let new_storage : Storage.Types.t = Test.get_storage typed_address_multi in
    let proposal : Storage.Types.proposal = match Map.find_opt 1n new_storage.proposal_map with
        Some value -> value
      | None -> failwith "f"
    in
    let () = assert ( proposal.approved_signers = (Set.add alice (Set.empty : address set)) ) in
    let () = assert ( proposal.executed = false) in
    let () = assert ( proposal.number_of_signer = 1n) in
    let () = assert ( proposal.target_fa12 = new_proposal.target_fa12) in
    let () = assert ( proposal.target_to = echo) in
    //let () = assert ( proposal.timestamp = (Tezos.now : timestamp)) in
    let () = assert ( proposal.token_amount = 100n) in
    "✓"

let test_sign_a_multisig_proposal_should_work =
    // Prepare data for initial storage
    let empty_bigmap : (nat, Storage.Types.proposal) big_map = Big_map.empty in 
    let address_1 : address = alice in
    let address_2 : address = bob in
    let address_3 : address = charly in
    // Create the initial multisig storage with specific values
    let initial_storage_multisig : Storage.Types.t = {
        proposal_counter = 0n;
        proposal_map = empty_bigmap;
        signers = (Set.add address_1 (Set.add address_2 (Set.add address_3 (Set.empty : address set))));
        threshold = 2n;
    } in
    // Originate contract multisig and cast a typed address to get the contract artefact
    let (typed_address_multi,contract_multisig) = originate initial_storage_multisig Multisign.main in
    // Create the initial fa12 storage
    let empty_bigmap : (FA12_Parameter.Types.allowance_key, nat) big_map = Big_map.empty in 
    let initial_storage_fa12 : FA12_Storage.Types.t = {
        tokens = Big_map.add alice 1000n Big_map.empty;
        allowances = empty_bigmap;
        total_supply = 1000n;
    } in
    // Originate contract fa12 and cast a typed address to get the contract artefact
    let (typed_address_fa,contract_fa12) = originate initial_storage_fa12 FA12.main in
    // Create a new proposal
    let new_proposal : Parameter.Types.proposal_params = {
        target_fa12 = Tezos.address contract_fa12;
        target_to = echo;
        token_amount = 100n;
    } in
    // Send a new proposal with a signer should work
    let () = Test.set_source alice in
    let tx : test_exec_result = Test.transfer_to_contract contract_multisig (Create_proposal(new_proposal)) 0mutez in
    let () = Test.set_source bob in
    let tx2 : test_exec_result = Test.transfer_to_contract contract_multisig (Sign_proposal(1n)) 0mutez in
 
    let new_storage : Storage.Types.t = Test.get_storage typed_address_multi in
    let proposal : Storage.Types.proposal = match Map.find_opt 1n new_storage.proposal_map with
        Some value -> value
      | None -> failwith "f"
    in

    //let () = assert ( proposal.approved_signers = (Set.add bob (Set.add alice (Set.empty : address set)))) in
    //let () = assert ( proposal.executed = true) in
    //let () = assert ( proposal.number_of_signer = 2n) in
    let () = assert ( proposal.target_fa12 = new_proposal.target_fa12) in
    let () = assert ( proposal.target_to = echo) in
    //let () = assert ( proposal.timestamp = (Tezos.now : timestamp)) in
    let () = assert ( proposal.token_amount = 100n) in
    "✓"



    