#import "../../../contracts/cameligo/betting/types.mligo" "TYPES"

(* Assert contract result is successful *)
let tx_success (res: test_exec_result) : unit =
    match res with
        | Fail (Rejected (error,_)) -> let () = Test.log(error) in Test.failwith "Transaction should not fail"
        | Fail _ -> Test.failwith "Transaction should not fail"
        | Success(_) -> Test.log("tx_success :", res)

(* Assert contract call results in Test.failwith with given string *)
let string_failure (res : test_exec_result) (expected : string) : unit =
    let _expected = Test.eval expected in
    let () = match res with
        | Fail (Rejected (actual,_)) -> assert (actual = _expected)
        | Fail (Balance_too_low _) -> Test.failwith "Contract failed: Balance too low"
        | Fail (Other s) -> Test.failwith s
        | Success _ -> Test.failwith "Transaction should fail"
    in
    Test.log("OK :", expected)

(* Assert Manager parameter with expected result *)
let assert_manager (ctr_taddr : (TYPES.action, TYPES.storage) typed_address) (expected : address) : unit =
    let ctr_storage : TYPES.storage = Test.get_storage(ctr_taddr) in
    let ctr_value : address = (ctr_storage.manager) in
    if (ctr_value = expected)
        then Test.log("OK", ctr_value)
        else Test.failwith("NOT OK", ctr_value)

(* Assert Oracle parameter with expected result *)
let assert_oracle (ctr_taddr : (TYPES.action, TYPES.storage) typed_address) (expected : address) : unit =
    let ctr_storage : TYPES.storage = Test.get_storage(ctr_taddr) in
    let ctr_value : address = (ctr_storage.oracleAddress) in
    if (ctr_value = expected)
        then Test.log("OK", ctr_value)
        else Test.failwith("NOT OK", ctr_value)

(* Assert isPaused parameter with expected result *)
let assert_ispaused (ctr_taddr : (TYPES.action, TYPES.storage) typed_address) (expected : bool) : unit =
    let ctr_storage : TYPES.storage = Test.get_storage(ctr_taddr) in
    let ctr_value : bool = (ctr_storage.betConfig.isBettingPaused) in
    if (ctr_value = expected)
        then Test.log("OK", ctr_value)
        else Test.failwith("NOT OK", ctr_value)

(* Assert isPaused parameter with expected result *)
let assert_eventsMap (ctr_taddr : (TYPES.action, TYPES.storage) typed_address) (expected : (nat, TYPES.eventType) map) : unit =
    let ctr_storage = Test.get_storage(ctr_taddr) in
    let ctr_value : (nat, TYPES.eventType) map = (ctr_storage.events) in
    if (ctr_value = expected)
        then Test.log("OK", ctr_value)
        else Test.failwith("NOT OK", ctr_value)