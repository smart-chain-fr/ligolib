#import "../../src/contracts/cameligo/oracle/errors.mligo" "Errors"
#import "helpers/bootstrap.mligo" "Bootstrap"
#import "helpers/helper.mligo" "Helper"
#import "helpers/assert.mligo" "Assert"
#import "../common/log.mligo" "Log"

let () = Log.describe("[Oracle - ChangeManager] test suite")

let test_change_manager_from_manager_should_work =
    let (oracle_contract, oracle_taddress, elon, jeff, _, _, _) = Bootstrap.bootstrap_oracle() in
    let () = Assert.manager oracle_taddress elon in

    let ret = Helper.trsc_change_manager (oracle_contract, elon, jeff) in
    let () = Assert.tx_success ret in
    let () = Assert.manager oracle_taddress jeff in
    "OK"

let test_change_manager_from_signer_should_work =
    let (oracle_contract, oracle_taddress, elon, jeff, _, _, _) = Bootstrap.bootstrap_oracle() in
    let () = Assert.manager oracle_taddress elon in

    let ret = Helper.trsc_change_manager (oracle_contract, jeff, jeff) in
    let () = Assert.string_failure ret Errors.not_manager in
    let () = Assert.manager oracle_taddress elon in
    "OK"

let test_change_manager_from_unauthorized_address_should_not_work =
    let (oracle_contract, oracle_taddress, elon, _, alice, _, _) = Bootstrap.bootstrap_oracle() in
    let () = Assert.manager oracle_taddress elon in

    let ret = Helper.trsc_change_manager (oracle_contract, alice, alice) in
    let () = Assert.string_failure ret Errors.not_manager in
    let () = Assert.manager oracle_taddress elon in
    "OK"