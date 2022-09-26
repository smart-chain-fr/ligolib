#import "../../../src/contracts/cameligo/betting/types.mligo" "Types"
#import "../../../src/contracts/cameligo/betting/callback/main.mligo" "Betting_Callback"

(* Assert contract result is successful *)
let tx_success (res: test_exec_result) : unit =
    match res with
        | Fail (Rejected (error,_)) -> let () = Test.log(error) in failwith "Transaction should not fail"
        | Fail _ -> failwith "Transaction should not fail"
        | Success(_) -> ()

(* Assert contract call results in failwith with given string *)
let string_failure (res : test_exec_result) (expected : string) : unit =
    let _expected = Test.eval expected in
    match res with
        | Fail (Rejected (actual,_)) -> assert (actual = _expected)
        | Fail (Balance_too_low _) -> failwith "Contract failed: Balance too low"
        | Fail (Other s) -> failwith s
        | Success _ -> failwith "Transaction should fail"

(* Assert Manager parameter with expected result *)
let balance (p_address : address) (expected : tez) : unit =
    let balance_value : tez = Test.get_balance(p_address) in
    assert (balance_value = expected)

(* Assert Manager parameter with expected result *)
let manager (ctr_taddr : (Types.action, Types.storage) typed_address) (expected : address) : unit =
    let ctr_storage : Types.storage = Test.get_storage(ctr_taddr) in
    let ctr_value : address = (ctr_storage.manager) in
    assert (ctr_value = expected)

(* Assert Oracle Address parameter with expected result *)
let oracle (ctr_taddr : (Types.action, Types.storage) typed_address) (expected : address) : unit =
    let ctr_storage : Types.storage = Test.get_storage(ctr_taddr) in
    let ctr_value : address = (ctr_storage.oracle_address) in
    assert (ctr_value = expected)
(* Assert is_betting_paused parameter with expected result *)
let is_betting_paused (ctr_taddr : (Types.action, Types.storage) typed_address) (expected : bool) : unit =
    let ctr_storage : Types.storage = Test.get_storage(ctr_taddr) in
    let ctr_value : bool = (ctr_storage.bet_config.is_betting_paused) in
    assert(ctr_value = expected)

(* Assert isPauseis_event_creation_pausedd parameter with expected result *)
let is_event_creation_paused (ctr_taddr : (Types.action, Types.storage) typed_address) (expected : bool) : unit =
    let ctr_storage : Types.storage = Test.get_storage(ctr_taddr) in
    let ctr_value : bool = (ctr_storage.bet_config.is_event_creation_paused) in
    assert (ctr_value = expected)

(* Assert Events Map parameter with expected result *)
let events_map (ctr_taddr : (Types.action, Types.storage) typed_address) (expected : (nat, Types.event_type) big_map) : unit =
    let ctr_storage = Test.get_storage(ctr_taddr) in
    let ctr_value : (nat, Types.event_type) big_map = (ctr_storage.events) in
    assert (ctr_value = expected)

(* Assert Events Bets Map parameter with expected result *)
let events_bet_map (ctr_taddr : (Types.action, Types.storage) typed_address) (expected : (nat, Types.event_bets) big_map) : unit =
    let ctr_storage = Test.get_storage(ctr_taddr) in
    let ctr_value : (nat, Types.event_bets) big_map = (ctr_storage.events_bets) in
    assert (ctr_value = expected)

let event (taddr : (Betting_Callback.parameter, Betting_Callback.storage) typed_address) (expected_event : Types.event_type) : unit =
    let storage = Test.get_storage(taddr) in
    let () = assert(storage.name=expected_event.name) in
    let () = assert(storage.videogame=expected_event.videogame) in
    let () = assert(storage.begin_at=expected_event.begin_at) in
    let () = assert(storage.end_at=expected_event.end_at) in
    let () = assert(storage.modified_at=expected_event.modified_at) in
    let () = assert(storage.opponents=expected_event.opponents) in
    let () = assert(storage.game_status=expected_event.game_status) in
    ()