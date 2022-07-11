#import "../../../contracts/cameligo/oracle/main.mligo" "ORACLE"
#import "../../../contracts/cameligo/oracle/types.mligo" "TYPES"

// let base_config = {
//     init_token_supply = 777777777777n;
//     init_token_balance = 1000n;
//     burn_rate = 7n;
//     reserve_rate = 1n;
//     allwn_amount = 300n;
//     tsfr_amount = 200n;
//     burn_address = ("tz1burnburnburnburnburnburnburjAYjjX": address);
//     reserve_address = ("tz1djkbrkYiuWFTgd3qUiViijGUuz2wBGxQ2": address);
//     random_contract_address = ("KT1MsktCnwfS1nGZmf8QbaTpZ8euVijWdmkC": address)
// }

let get_storage(addr : (TYPES.action, TYPES.storage) typed_address) : TYPES.storage =
    let oracle_storage : TYPES.storage = Test.get_storage addr in
    oracle_storage

let trscChangeManager(contr, from_ : TYPES.action contract * address) =
    let () = Test.set_source from_ in
    let result : test_exec_result = Test.transfer_to_contract contr (SwitchPause) 0tez in
    result

let trscChangeSigner(contr, from_ : TYPES.action contract * address) =
    let () = Test.set_source from_ in
    let result : test_exec_result = Test.transfer_to_contract contr (SwitchPause) 0tez in
    result

let trscSwitchPause(contr, from_ : TYPES.action contract * address) =
    let () = Test.set_source from_ in
    let result : test_exec_result = Test.transfer_to_contract contr (SwitchPause) 0tez in
    result


// let get_balance_from_storage(anti_address, owner_address : (ANTI.parameter, ANTI.storage) typed_address * address) : nat =
//     let anti_storage : ANTI.storage = Test.get_storage anti_address in
//     let retrieved_balance_opt : nat option = Big_map.find_opt owner_address anti_storage.ledger in
//     let retrieved_balance = match retrieved_balance_opt with    
//         | Some x -> x
//         | None -> 0n
//     in
//     retrieved_balance

// let transfer(contr, from_, to_, amount_ : ANTI.parameter contract * address * address * nat) =
//     let () = Test.set_source from_ in
//     let transfer_requests = ({address_from=from_; address_to=to_; value=amount_} : ANTI.transfer) in
//     Test.transfer_to_contract contr (Transfer transfer_requests) 0tez
