#import "../../../contracts/cameligo/oracle/main.mligo" "ORACLE"
#import "../../../contracts/cameligo/oracle/types.mligo" "TYPES"
#import "./bootstrap.mligo" "BOOTSTRAP"

//  VARIABLES

let emptyMap : (nat, TYPES.event_type) map = (Map.empty : (nat, TYPES.event_type) map)

let oneEventMap : (nat, TYPES.event_type) map = Map.literal [
    (0n, BOOTSTRAP.primaryEvent)
    ]
let doubleEventMap : (nat, TYPES.event_type) map = Map.literal [
    (0n, BOOTSTRAP.primaryEvent);
    (1n, BOOTSTRAP.primaryEvent)
    ]
let threeEventMap : (nat, TYPES.event_type) map = Map.literal [
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
    let result : test_exec_result = Test.transfer_to_contract contr (ChangeManager new_) 0mutez in
    result

let trscChangeSigner(contr, from, new_ : TYPES.action contract * address * address) =
    let () = Test.set_source from in
    let result : test_exec_result = Test.transfer_to_contract contr (ChangeSigner new_) 0mutez in
    result

let trscSwitchPause(contr, from : TYPES.action contract * address) =
    let () = Test.set_source from in
    let result : test_exec_result = Test.transfer_to_contract contr (SwitchPause) 0mutez in
    result

let trscAddEvent(contr, from, event : TYPES.action contract * address * TYPES.event_type) =
    let () = Test.set_source from in
    let result : test_exec_result = Test.transfer_to_contract contr (AddEvent event) 0mutez in
    result

let trscUpdateEvent(contr, from, event_num, event : TYPES.action contract * address * nat * TYPES.event_type) =
    let () = Test.set_source from in
    let updateEventParam : TYPES.update_event_parameter =
    {
        updated_event_id = event_num;
        updated_event = event;
    }
    in
    let result : test_exec_result = Test.transfer_to_contract contr (UpdateEvent updateEventParam) 0mutez in
    result

let trscGetEvent(contr, from, cbk_addr, event_num : TYPES.action contract * address * address * nat) =
    let () = Test.set_source from in
    let callbackParameter : TYPES.callback_asked_parameter =
    {
        requested_event_id = event_num;
        callback = cbk_addr
    } in
    let result_cbk = Test.transfer_to_contract contr (GetEvent callbackParameter) 0mutez in
    result_cbk
