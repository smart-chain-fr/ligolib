#import "../../../contracts/cameligo/betting/main.mligo" "BETTING"
#import "../../../contracts/cameligo/betting/types.mligo" "TYPES"
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

let emptyBetMap : (nat, TYPES.eventBets) map = (Map.empty : (nat, TYPES.eventBets) map)

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

let trscAddEvent(contr, from, event : TYPES.action contract * address * TYPES.eventType) =
    let () = Test.set_source from in
    let result : test_exec_result = Test.transfer_to_contract contr (AddEvent event) 0mutez in
    result

let trscUpdateEvent(contr, from, event_num, event : TYPES.action contract * address * nat * TYPES.eventType) =
    let () = Test.set_source from in
    let updateEventParam : TYPES.updateEventParameter =
    {
        updatedEventID = event_num;
        updatedEvent = event;
    }
    in
    let result : test_exec_result = Test.transfer_to_contract contr (UpdateEvent updateEventParam) 0mutez in
    result

let trscGetEvent(contr, from, cbk_addr, event_num : TYPES.action contract * address * address * nat) =
    let () = Test.set_source from in
    let callbackParameter : TYPES.callbackAskedParameter =
    {
        requestedEventID = event_num;
        callback = cbk_addr
    } in
    let result_cbk = Test.transfer_to_contract contr (GetEvent callbackParameter) 0mutez in
    result_cbk

let trscAddBet  (contr, from, pRequestedEventID, pTeamOneBet, pBetAmount : TYPES.action contract * address * nat * bool * tez) =
    let () = Test.set_source from in
    let addBetParam : TYPES.addBetParameter = {
        requestedEventID = pRequestedEventID;
        teamOneBet = pTeamOneBet
    } in
    let result_tx = Test.transfer_to_contract contr (AddBet addBetParam) pBetAmount in
    result_tx

let trscFinalizeBet(contr, from, pRequestedEventID : TYPES.action contract * address * nat) =
    let () = Test.set_source from in
    let result_tx = Test.transfer_to_contract contr (FinalizeBet pRequestedEventID) 0mutez in
    result_tx
