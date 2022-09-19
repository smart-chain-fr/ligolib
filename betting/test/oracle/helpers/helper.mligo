#import "../../../src/contracts/cameligo/oracle/types.mligo" "Types"
#import "bootstrap.mligo" "Bootstrap"
#import "assert.mligo" "Assert"

//  VARIABLES

let empty_map : (nat, Types.event_type) map = (Map.empty : (nat, Types.event_type) map)

let one_event_map : (nat, Types.event_type) map = Map.literal [
    (0n, Bootstrap.primary_event)
    ]
let double_event_map : (nat, Types.event_type) map = Map.literal [
    (0n, Bootstrap.primary_event);
    (1n, Bootstrap.primary_event)
    ]
let three_event_map : (nat, Types.event_type) map = Map.literal [
    (0n, Bootstrap.primary_event);
    (1n, Bootstrap.primary_event);
    (2n, Bootstrap.primary_event)
    ]

//  FUNCTIONS

let trsc_change_manager(contr, from, new : Types.action contract * address * address) =
    let () = Test.set_source from in
    let result : test_exec_result = Test.transfer_to_contract contr (ChangeManager new) 0mutez in
    result

let trsc_change_manager_success(contr, from, new : Types.action contract * address * address) =
  Assert.tx_success (trsc_change_manager(contr, from, new))

let trsc_change_signer(contr, from, new : Types.action contract * address * address) =
    let () = Test.set_source from in
    let result : test_exec_result = Test.transfer_to_contract contr (ChangeSigner new) 0mutez in
    result

let trsc_change_signer_success(contr, from, new : Types.action contract * address * address) =
  Assert.tx_success (trsc_change_signer(contr, from, new))

let trsc_switch_pause(contr, from : Types.action contract * address) =
    let () = Test.set_source from in
    let result : test_exec_result = Test.transfer_to_contract contr (SwitchPause) 0mutez in
    result

let trsc_switch_pause_success(contr, from : Types.action contract * address) =
  Assert.tx_success (trsc_switch_pause(contr, from))

let trsc_add_event(contr, from, event : Types.action contract * address * Types.event_type) =
    let () = Test.set_source from in
    let result : test_exec_result = Test.transfer_to_contract contr (AddEvent event) 0mutez in
    result

let trsc_add_event_success(contr, from, event : Types.action contract * address * Types.event_type) =
  Assert.tx_success (trsc_add_event(contr, from, event))

let trsc_update_event(contr, from, event_num, event : Types.action contract * address * nat * Types.event_type) =
    let () = Test.set_source from in
    let updateEventParam : Types.update_event_parameter =
    {
        updated_event_id = event_num;
        updated_event = event;
    }
    in
    let result : test_exec_result = Test.transfer_to_contract contr (UpdateEvent updateEventParam) 0mutez in
    result

let trsc_update_event_success(contr, from, event_num, event : Types.action contract * address * nat * Types.event_type) =
  Assert.tx_success (trsc_update_event(contr, from, event_num, event))

let trsc_get_event(contr, from, cbk_addr, event_num : Types.action contract * address * address * nat) =
    let () = Test.set_source from in
    let callbackParameter : Types.callback_asked_parameter =
    {
        requested_event_id = event_num;
        callback = cbk_addr
    } in
    let result_cbk = Test.transfer_to_contract contr (GetEvent callbackParameter) 0mutez in
    result_cbk

let trsc_get_event_success(contr, from, cbk_addr, event_num : Types.action contract * address * address * nat) =
  Assert.tx_success (trsc_get_event(contr, from, cbk_addr, event_num))