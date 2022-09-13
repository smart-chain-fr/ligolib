#import "../../../contracts/cameligo/oracle/types.mligo" "TYPES"
#import "../../../contracts/cameligo/oracle/callback/main.mligo" "ORACLE_CALLBACK"
#import "../../../contracts/cameligo/oracle/errors.mligo" "ORACLE_ERRORS"

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
let assert_manager (ctr_taddr : (TYPES.action, TYPES.storage) typed_address) (expected : address) : unit =
    let ctr_storage : TYPES.storage = Test.get_storage(ctr_taddr) in
    let ctr_value : address = (ctr_storage.manager) in
    if (ctr_value = expected)
        then Test.log("OK", ctr_value)
        else failwith("NOT OK", ctr_value)

(* Assert Signer parameter with expected result *)
let assert_signer (ctr_taddr : (TYPES.action, TYPES.storage) typed_address) (expected : address) : unit =
    let ctr_storage : TYPES.storage = Test.get_storage(ctr_taddr) in
    let ctr_value : address = (ctr_storage.signer) in
    if (ctr_value = expected)
        then Test.log("OK", ctr_value)
        else failwith("NOT OK", ctr_value)

(* Assert isPaused parameter with expected result *)
let assert_ispaused (ctr_taddr : (TYPES.action, TYPES.storage) typed_address) (expected : bool) : unit =
    let ctr_storage : TYPES.storage = Test.get_storage(ctr_taddr) in
    let ctr_value : bool = (ctr_storage.isPaused) in
    if (ctr_value = expected)
        then Test.log("OK", ctr_value)
        else failwith("NOT OK", ctr_value)

(* Assert isPaused parameter with expected result *)
let assert_eventsMap (ctr_taddr : (TYPES.action, TYPES.storage) typed_address) (expected : (nat, TYPES.event_type) map) : unit =
    let ctr_storage = Test.get_storage(ctr_taddr) in
    let ctr_value : (nat, TYPES.event_type) map = (ctr_storage.events) in
    if (ctr_value = expected)
        then Test.log("OK", ctr_value)
        else failwith("NOT OK", ctr_value)

let assert_event (taddr : (ORACLE_CALLBACK.parameter, ORACLE_CALLBACK.storage) typed_address) (expected_event : TYPES.event_type) : unit =
    let storage = Test.get_storage(taddr) in
    let () = Test.log(storage) in
    let () = Test.log(expected_event) in
    let () = assert(storage.name=expected_event.name) in
    let () = assert(storage.videogame=expected_event.videogame) in
    let () = assert(storage.begin_at=expected_event.begin_at) in
    let () = assert(storage.end_at=expected_event.end_at) in
    let () = assert(storage.modified_at=expected_event.modified_at) in
    let () = assert(storage.opponents=expected_event.opponents) in
    let () = assert(storage.isFinalized=expected_event.isFinalized) in
    let () = assert(storage.isDraw=expected_event.isDraw) in
    assert(storage.isTeamOneWin=expected_event.isTeamOneWin)
