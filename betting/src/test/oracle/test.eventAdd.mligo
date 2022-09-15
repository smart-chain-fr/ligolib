#import "../../contracts/cameligo/oracle/errors.mligo" "Errors"
#import "helpers/bootstrap.mligo" "Bootstrap"
#import "helpers/helper.mligo" "Helper"
#import "helpers/assert.mligo" "Assert"
#import "helpers/log.mligo" "Log"

let () = Log.describe("[EventAdd] test suite")

let test_add_event_from_manager_should_work =
    let (oracle_contract, oracle_taddress, elon, _, _, _, _) = Bootstrap.bootstrap_oracle() in
    let () = Assert.assert_eventsMap oracle_taddress Helper.empty_map in
    let () = Helper.trsc_add_event_success (oracle_contract, elon, Bootstrap.primary_event) in
    Assert.assert_eventsMap oracle_taddress Helper.one_event_map

let test_add_event_from_signer_should_work =
    let (oracle_contract, oracle_taddress, _, jeff, _, _, _) = Bootstrap.bootstrap_oracle() in
    let () = Assert.assert_eventsMap oracle_taddress Helper.empty_map in
    let () = Helper.trsc_add_event_success (oracle_contract, jeff, Bootstrap.primary_event) in
    Assert.assert_eventsMap oracle_taddress Helper.one_event_map

let test_add_event_from_unauthorized_address_should_not_work =
    let (oracle_contract, oracle_taddress, _, _, alice, _, _) = Bootstrap.bootstrap_oracle() in
    let () = Assert.assert_eventsMap oracle_taddress Helper.empty_map in
    let ret = Helper.trsc_add_event (oracle_contract, alice, Bootstrap.primary_event) in
    let () = Assert.string_failure ret Errors.not_manager_nor_signer in
    Assert.assert_eventsMap oracle_taddress Helper.empty_map