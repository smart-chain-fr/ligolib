#import "../../../src/contracts/cameligo/betting/main.mligo" "Betting"
#import "../../../src/contracts/cameligo/betting/types.mligo" "Types"
#import "bootstrap.mligo" "Bootstrap"
#import "assert.mligo" "Assert"
#import "events.mligo" "Events"

//  VARIABLES

let empty_map : (nat, Types.event_type) big_map = (Big_map.empty : (nat, Types.event_type) big_map)

let one_event_map : (nat, Types.event_type) big_map = Big_map.literal [
  (0n, Events.primary_event)
  ]
let double_event_map : (nat, Types.event_type) big_map = Big_map.literal [
  (0n, Events.primary_event);
  (1n, Events.primary_event)
  ]
let three_event_map : (nat, Types.event_type) big_map = Big_map.literal [
  (0n, Events.primary_event);
  (1n, Events.primary_event);
  (2n, Events.primary_event)
  ]

let empty_bet_map : (nat, Types.event_bets) big_map = (Big_map.empty : (nat, Types.event_bets) big_map)

    
//  FAILWITH Helper

let assert_string_failure (res : test_exec_result) (expected : string) : unit =
  let expected = Test.eval expected in
  match res with
  | Fail (Rejected (actual,_)) -> assert (Test.michelson_equal actual expected)
  | Fail (Balance_too_low _p) -> failwith "contract failed: balance too low"
  | Fail (Other s) -> failwith s
  | Success _gas -> failwith "contract did not failed but was expected to fail"


//  FUNCTIONS

let trsc_change_manager(contr, from, new_ : Types.action contract * address * address) =
  let () = Test.set_source from in
  let result : test_exec_result = Test.transfer_to_contract contr (ChangeManager new_) 0mutez in
  result

let trsc_change_manager_success(contr, from, new_ : Types.action contract * address * address) =
  Assert.tx_success (trsc_change_manager(contr, from, new_))

let trsc_change_oracle_address(contr, from, new_ : Types.action contract * address * address) =
  let () = Test.set_source from in
  let result : test_exec_result = Test.transfer_to_contract contr (ChangeOracleAddress new_) 0mutez in
  result

let trsc_change_oracle_address_success(contr, from, new_ : Types.action contract * address * address) =
  Assert.tx_success (trsc_change_oracle_address(contr, from, new_))

let trsc_switch_pauseBetting(contr, from : Types.action contract * address) =
  let () = Test.set_source from in
  let result : test_exec_result = Test.transfer_to_contract contr (SwitchPauseBetting) 0mutez in
  result

let trsc_switch_pauseBetting_success(contr, from : Types.action contract * address) =
  Assert.tx_success (trsc_switch_pauseBetting(contr, from))

let trsc_switch_pauseEventCreation(contr, from : Types.action contract * address) =
  let () = Test.set_source from in
  let result : test_exec_result = Test.transfer_to_contract contr (SwitchPauseEventCreation) 0mutez in
  result

let trsc_switch_pauseEventCreation_success(contr, from : Types.action contract * address) =
  Assert.tx_success (trsc_switch_pauseEventCreation(contr, from))

let trsc_add_event(contr, from, event : Types.action contract * address * Types.add_event_parameter) =
  let () = Test.set_source from in
  let result : test_exec_result = Test.transfer_to_contract contr (AddEvent event) 0mutez in
  result

let trsc_add_event_success(contr, from, event : Types.action contract * address * Types.add_event_parameter) =
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

let trsc_add_bet(contr, from, pRequestedEventID, pTeamOneBet, pBetAmount : Types.action contract * address * nat * bool * tez) =
  let () = Test.set_source from in
  let addBetParam : Types.add_bet_parameter = {
      requested_event_id = pRequestedEventID;
      team_one_bet = pTeamOneBet
  } in
  let result_tx = Test.transfer_to_contract contr (AddBet addBetParam) pBetAmount in
  result_tx

let trsc_add_bet_success(contr, from, pRequestedEventID, pTeamOneBet, pBetAmount : Types.action contract * address * nat * bool * tez) =
  Assert.tx_success (trsc_add_bet(contr, from, pRequestedEventID, pTeamOneBet, pBetAmount))

let trsc_finalize_bet(contr, from, pRequestedEventID : Types.action contract * address * nat) =
  let () = Test.set_source from in
  let result_tx = Test.transfer_to_contract contr (FinalizeBet pRequestedEventID) 0mutez in
  result_tx

let trsc_finalize_bet_success(contr, from, pRequestedEventID : Types.action contract * address * nat) =
  Assert.tx_success (trsc_finalize_bet(contr, from, pRequestedEventID))
