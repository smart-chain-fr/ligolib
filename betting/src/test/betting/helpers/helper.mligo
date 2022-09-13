#import "../../../contracts/cameligo/betting/main.mligo" "BETTING"
#import "../../../contracts/cameligo/betting/types.mligo" "TYPES"
#import "./bootstrap.mligo" "BOOTSTRAP"

//  VARIABLES

let emptyMap : (nat, TYPES.event_type) big_map = (Big_map.empty : (nat, TYPES.event_type) big_map)

let oneEventMap : (nat, TYPES.event_type) big_map = Big_map.literal [
  (0n, BOOTSTRAP.primaryEvent)
  ]
let doubleEventMap : (nat, TYPES.event_type) big_map = Big_map.literal [
  (0n, BOOTSTRAP.primaryEvent);
  (1n, BOOTSTRAP.primaryEvent)
  ]
let threeEventMap : (nat, TYPES.event_type) big_map = Big_map.literal [
  (0n, BOOTSTRAP.primaryEvent);
  (1n, BOOTSTRAP.primaryEvent);
  (2n, BOOTSTRAP.primaryEvent)
  ]

let emptyBetMap : (nat, TYPES.event_bets) big_map = (Big_map.empty : (nat, TYPES.event_bets) big_map)

    
//  FAILWITH HELPER

let assert_string_failure (res : test_exec_result) (expected : string) : unit =
  let expected = Test.eval expected in
  match res with
  | Fail (Rejected (actual,_)) -> assert (Test.michelson_equal actual expected)
  | Fail (Balance_too_low _p) -> failwith "contract failed: balance too low"
  | Fail (Other s) -> failwith s
  | Success _gas -> failwith "contract did not failed but was expected to fail"


//  FUNCTIONS

let printStorage (ctr_taddr : (TYPES.action, TYPES.storage) typed_address) : unit =
  let ctr_storage = Test.get_storage(ctr_taddr) in
  Test.log("Storage :", ctr_storage)

let trscChangeManager(contr, from, new_ : TYPES.action contract * address * address) =
  let () = Test.set_source from in
  let result : test_exec_result = Test.transfer_to_contract contr (ChangeManager new_) 0mutez in
  result

let trscChangeOracleAddress(contr, from, new_ : TYPES.action contract * address * address) =
  let () = Test.set_source from in
  let result : test_exec_result = Test.transfer_to_contract contr (ChangeOracleAddress new_) 0mutez in
  result

let trscSwitchPauseBetting(contr, from : TYPES.action contract * address) =
  let () = Test.set_source from in
  let result : test_exec_result = Test.transfer_to_contract contr (SwitchPauseBetting) 0mutez in
  result

let trscSwitchPauseEventCreation(contr, from : TYPES.action contract * address) =
  let () = Test.set_source from in
  let result : test_exec_result = Test.transfer_to_contract contr (SwitchPauseEventCreation) 0mutez in
  result

let trscAddEvent(contr, from, event : TYPES.action contract * address * TYPES.add_event_parameter) =
  let () = Test.set_source from in
  let result : test_exec_result = Test.transfer_to_contract contr (AddEvent event) 0mutez in
  result

let trscUpdateEvent(contr, from, event_num, event : TYPES.action contract * address * nat * TYPES.event_type) =
  let () = Test.set_source from in
  let updateEventParam : TYPES.update_event_parameter =
  {
      updatedEventID = event_num;
      updatedEvent = event;
  }
  in
  let result : test_exec_result = Test.transfer_to_contract contr (UpdateEvent updateEventParam) 0mutez in
  result

let trscGetEvent(contr, from, cbk_addr, event_num : TYPES.action contract * address * address * nat) =
  let () = Test.set_source from in
  let callbackParameter : TYPES.callback_asked_parameter =
  {
      requestedEventID = event_num;
      callback = cbk_addr
  } in
  let result_cbk = Test.transfer_to_contract contr (GetEvent callbackParameter) 0mutez in
  result_cbk

let trscAddBet  (contr, from, pRequestedEventID, pTeamOneBet, pBetAmount : TYPES.action contract * address * nat * bool * tez) =
  let () = Test.set_source from in
  let addBetParam : TYPES.add_bet_parameter = {
      requestedEventID = pRequestedEventID;
      teamOneBet = pTeamOneBet
  } in
  let result_tx = Test.transfer_to_contract contr (AddBet addBetParam) pBetAmount in
  result_tx

let trscFinalizeBet(contr, from, pRequestedEventID : TYPES.action contract * address * nat) =
  let () = Test.set_source from in
  let result_tx = Test.transfer_to_contract contr (FinalizeBet pRequestedEventID) 0mutez in
  result_tx
