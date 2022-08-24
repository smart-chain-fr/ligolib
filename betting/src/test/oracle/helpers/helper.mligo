#import "../../../contracts/cameligo/oracle/main.mligo" "ORACLE"
#import "../../../contracts/cameligo/oracle/types.mligo" "TYPES"
#import "./bootstrap.mligo" "BOOTSTRAP"

//  VARIABLES

let emptyMap : (nat, TYPES.eventType) map = (Map.empty : (nat, TYPES.eventType) map)

let oneEventMap : (nat, TYPES.eventType) map = Map.literal [
    (0n, BOOTSTRAP.primaryEvent)
    ]
let doubleEventMap : (nat, TYPES.eventType) map = Map.literal [
    (0n, BOOTSTRAP.primaryEvent);
    (1n, BOOTSTRAP.primaryEvent)
    ]
let threeEventMap : (nat, TYPES.eventType) map = Map.literal [
    (0n, BOOTSTRAP.primaryEvent);
    (1n, BOOTSTRAP.primaryEvent);
    (2n, BOOTSTRAP.primaryEvent)
    ]

//  FUNCTIONS

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

let trscGetEvent(contr, from, cbk_addr, event_num : TYPES.action contract * address * address * nat) =
    let () = Test.set_source from in
    let callbackParameter : TYPES.callbackAskedParameter =
    {
        requestedEventID = event_num;
        callback = cbk_addr
    } in
    let result_cbk = Test.transfer_to_contract contr (GetEvent callbackParameter) 0tez in
    result_cbk
