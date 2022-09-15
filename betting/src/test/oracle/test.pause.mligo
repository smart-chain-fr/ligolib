#import "../../contracts/cameligo/oracle/errors.mligo" "Errors"
#import "helpers/bootstrap.mligo" "Bootstrap"
#import "helpers/helper.mligo" "Helper"
#import "helpers/assert.mligo" "Assert"
#import "helpers/log.mligo" "Log"

let () = Log.describe("[SwitchPause] test suite")

let test_switch_pause_from_manager_should_work =
    let (oracle_contract, oracle_taddress, elon, _, _, _, _) = Bootstrap.bootstrap_oracle() in
    let () = Assert.assert_ispaused oracle_taddress false in

    let () = Helper.trsc_switch_pause_success (oracle_contract, elon) in
    let () = Assert.assert_ispaused oracle_taddress true in
    "OK"

let test_switch_pause_from_signer_should_not_work =
    let (oracle_contract, oracle_taddress, _, jeff, _, _, _) = Bootstrap.bootstrap_oracle() in
    let () = Assert.assert_ispaused oracle_taddress false in

    let ret = Helper.trsc_switch_pause (oracle_contract, jeff) in
    let () = Assert.string_failure ret Errors.not_manager in
    let () = Assert.assert_ispaused oracle_taddress false in
    "OK"

let test_switch_pause_from_unauthorized_address_should_not_work =
    let (oracle_contract, oracle_taddress, _, _, alice, _, _) = Bootstrap.bootstrap_oracle() in
    let () = Assert.assert_ispaused oracle_taddress false in

    let ret = Helper.trsc_switch_pause (oracle_contract, alice) in
    let () = Assert.string_failure ret Errors.not_manager in
    let () = Assert.assert_ispaused oracle_taddress false in
    "OK"
