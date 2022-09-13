#import "../../../contracts/cameligo/betting/types.mligo" "TYPES"

(* Assert contract result is successful *)
let tx_success (res: test_exec_result) : unit =
    match res with
        | Fail (Rejected (error,_)) -> let () = Test.log(error) in failwith "Transaction should not fail"
        | Fail _ -> failwith "Transaction should not fail"
        | Success(_) -> Test.log("tx_success :", res)

(* Assert contract call results in failwith with given string *)
let string_failure (res : test_exec_result) (expected : string) : unit =
    let _expected = Test.eval expected in
    let () = match res with
        | Fail (Rejected (actual,_)) -> assert (actual = _expected)
        | Fail (Balance_too_low _) -> failwith "Contract failed: Balance too low"
        | Fail (Other s) -> failwith s
        | Success _ -> failwith "Transaction should fail"
    in
    Test.log("OK :", expected)


(* Assert Manager parameter with expected result *)
let assert_balance (p_address : address) (expected : tez) : unit =
    let balance_value : tez = Test.get_balance(p_address) in
    if (balance_value = expected)
        then Test.log("OK", balance_value)
        else failwith("NOT OK", balance_value)

(* Assert Manager parameter with expected result *)
let assert_manager (ctr_taddr : (TYPES.action, TYPES.storage) typed_address) (expected : address) : unit =
    let ctr_storage : TYPES.storage = Test.get_storage(ctr_taddr) in
    let ctr_value : address = (ctr_storage.manager) in
    if (ctr_value = expected)
        then Test.log("OK", ctr_value)
        else failwith("NOT OK", ctr_value)

(* Assert Oracle Address parameter with expected result *)
let assert_oracle (ctr_taddr : (TYPES.action, TYPES.storage) typed_address) (expected : address) : unit =
    let ctr_storage : TYPES.storage = Test.get_storage(ctr_taddr) in
    let ctr_value : address = (ctr_storage.oracleAddress) in
    if (ctr_value = expected)
        then Test.log("OK", ctr_value)
        else failwith("NOT OK", ctr_value)

(* Assert isBettingPaused parameter with expected result *)
let assert_isBettingPaused (ctr_taddr : (TYPES.action, TYPES.storage) typed_address) (expected : bool) : unit =
    let ctr_storage : TYPES.storage = Test.get_storage(ctr_taddr) in
    let ctr_value : bool = (ctr_storage.betConfig.isBettingPaused) in
    if (ctr_value = expected)
        then Test.log("OK", ctr_value)
        else failwith("NOT OK", ctr_value)

(* Assert isPauseisEventCreationPausedd parameter with expected result *)
let assert_isEventCreationPaused (ctr_taddr : (TYPES.action, TYPES.storage) typed_address) (expected : bool) : unit =
    let ctr_storage : TYPES.storage = Test.get_storage(ctr_taddr) in
    let ctr_value : bool = (ctr_storage.betConfig.isEventCreationPaused) in
    if (ctr_value = expected)
        then Test.log("OK", ctr_value)
        else failwith("NOT OK", ctr_value)

(* Assert Events Map parameter with expected result *)
let assert_eventsMap (ctr_taddr : (TYPES.action, TYPES.storage) typed_address) (expected : (nat, TYPES.event_type) big_map) : unit =
    let ctr_storage = Test.get_storage(ctr_taddr) in
    let ctr_value : (nat, TYPES.event_type) big_map = (ctr_storage.events) in
    if (ctr_value = expected)
        then Test.log("OK", ctr_value)
        else failwith("NOT OK", ctr_value)

(* Assert Events Bets Map parameter with expected result *)
let assert_eventsBetMap (ctr_taddr : (TYPES.action, TYPES.storage) typed_address) (expected : (nat, TYPES.event_bets) big_map) : unit =
    let ctr_storage = Test.get_storage(ctr_taddr) in
    let ctr_value : (nat, TYPES.event_bets) big_map = (ctr_storage.events_bets) in
    if (ctr_value = expected)
        then Test.log("OK", ctr_value)
        else failwith("NOT OK", ctr_value)