#import "../../contracts/cameligo/oracle/errors.mligo" "Errors"
#import "../../contracts/cameligo/oracle/types.mligo" "Types"
#import "helpers/bootstrap.mligo" "Bootstrap"
#import "helpers/helper.mligo" "Helper"
#import "helpers/assert.mligo" "Assert"
#import "helpers/log.mligo" "Log"

let () = Log.describe("[EventUpdate] test suite")

let updated_eventMap : (nat, Types.event_type) map = Map.literal [
    (0n, Bootstrap.secondary_event)
    ]
let updated_three_event_map : (nat, Types.event_type) map = Map.literal [
    (0n, Bootstrap.primary_event);
    (1n, Bootstrap.primary_event);
    (2n, Bootstrap.secondary_event);
    ]

let test_update_event_from_manager_should_work =
    let (oracle_contract, oracle_taddress, elon, _, _, _, _) = Bootstrap.bootstrap_oracle() in
    let () = Helper.trsc_add_event_success (oracle_contract, elon, Bootstrap.primary_event) in
    let () = Assert.assert_events_map oracle_taddress Helper.one_event_map in

    let () = Helper.trsc_update_event_success (oracle_contract, elon, 0n, Bootstrap.secondary_event) in
    let () = Assert.assert_events_map oracle_taddress updated_eventMap in
    "OK"

let test_update_event_from_signer_should_work =
    let (oracle_contract, oracle_taddress, elon, jeff, _, _, _) = Bootstrap.bootstrap_oracle() in
    let () = Helper.trsc_add_event_success (oracle_contract, elon, Bootstrap.primary_event) in
    let () = Assert.assert_events_map oracle_taddress Helper.one_event_map in

    let () = Helper.trsc_update_event_success (oracle_contract, jeff, 0n, Bootstrap.secondary_event) in
    let () = Assert.assert_events_map oracle_taddress updated_eventMap in
    "OK"

let test_update_event_from_unauthorized_address_should_not_work =
    let (oracle_contract, oracle_taddress, elon, _, alice, _, _) = Bootstrap.bootstrap_oracle() in
    let () = Helper.trsc_add_event_success (oracle_contract, elon, Bootstrap.primary_event) in
    let () = Assert.assert_events_map oracle_taddress Helper.one_event_map in

    let ret = Helper.trsc_update_event (oracle_contract, alice, 0n, Bootstrap.secondary_event) in
    let () = Assert.string_failure ret Errors.not_manager_nor_signer in
    let () = Assert.assert_events_map oracle_taddress Helper.one_event_map in
    "OK"

let test_update_third_event_from_manager_should_work =
    let (oracle_contract, oracle_taddress, elon, _, _, _, _) = Bootstrap.bootstrap_oracle() in
    let () = Helper.trsc_add_event_success (oracle_contract, elon, Bootstrap.primary_event) in
    let () = Helper.trsc_add_event_success (oracle_contract, elon, Bootstrap.primary_event) in
    let () = Helper.trsc_add_event_success (oracle_contract, elon, Bootstrap.primary_event) in
    let () = Assert.assert_events_map oracle_taddress Helper.three_event_map in

    let () = Helper.trsc_update_event_success (oracle_contract, elon, 2n, Bootstrap.secondary_event) in
    let () = Assert.assert_events_map oracle_taddress updated_three_event_map in
    "OK"

let test_update_third_event_from_signer_should_work =
    let (oracle_contract, oracle_taddress, elon, jeff, _, _, _) = Bootstrap.bootstrap_oracle() in
    let () = Helper.trsc_add_event_success (oracle_contract, elon, Bootstrap.primary_event) in
    let () = Helper.trsc_add_event_success (oracle_contract, elon, Bootstrap.primary_event) in
    let () = Helper.trsc_add_event_success (oracle_contract, elon, Bootstrap.primary_event) in
    let () = Assert.assert_events_map oracle_taddress Helper.three_event_map in
    
    let () = Helper.trsc_update_event_success (oracle_contract, jeff, 2n, Bootstrap.secondary_event) in
    let () = Assert.assert_events_map oracle_taddress updated_three_event_map in
    "OK"