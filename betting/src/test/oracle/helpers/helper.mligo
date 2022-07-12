#import "../../../contracts/cameligo/oracle/main.mligo" "ORACLE"
#import "../../../contracts/cameligo/oracle/types.mligo" "TYPES"

let printStorage (ctr_taddr : (TYPES.action, TYPES.storage) typed_address) : unit =
    let ctr_storage = Test.get_storage(ctr_taddr) in
    Test.log("Storage :", ctr_storage)

let trscChangeManager(contr, from, new_ : TYPES.action contract * address * address) =
    let () = Test.set_source from in
    let result : test_exec_result = Test.transfer_to_contract contr (ChangeManager new_) 0tez in
    result

let trscChangeSigner(contr, from, new_ : TYPES.action contract * address * address) =
    let () = Test.set_source from in
    let result : test_exec_result = Test.transfer_to_contract contr (ChangeSigner new_) 0tez in
    result

let trscSwitchPause(contr, from : TYPES.action contract * address) =
    let () = Test.set_source from in
    let result : test_exec_result = Test.transfer_to_contract contr (SwitchPause) 0tez in
    result

let trscAddEvent(contr, from, event : TYPES.action contract * address * TYPES.eventType) =
    let () = Test.set_source from in
    let result : test_exec_result = Test.transfer_to_contract contr (AddEvent event) 0tez in
    result

let trscUpdateEvent(contr, from, event_num, event : TYPES.action contract * address * nat * TYPES.eventType) =
    let () = Test.set_source from in
    let updateEventParam : TYPES.updateEventParameter =
    {
        updatedEventID = event_num;
        updatedEvent = event;
    }
    in
    let result : test_exec_result = Test.transfer_to_contract contr (UpdateEvent updateEventParam) 0tez in
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
