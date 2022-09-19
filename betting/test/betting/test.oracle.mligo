#import "../../src/contracts/cameligo/betting/errors.mligo" "Errors"
#import "helpers/bootstrap.mligo" "Bootstrap"
#import "helpers/helper.mligo" "Helper"
#import "helpers/assert.mligo" "Assert"
#import "helpers/log.mligo" "Log"

let () = Log.describe("[Betting - ChangeOracleAddress] test suite")

let test_change_oracle_address_from_manager_should_work =
    let (_, betting_contract, betting_taddress, elon, jeff, _, _, _) = Bootstrap.bootstrap() in
    let () = Assert.oracle betting_taddress jeff in

    let () = Helper.trsc_change_oracle_address_success(betting_contract, elon, elon) in
    let () = Assert.oracle betting_taddress elon in
    "OK"

let test_change_oracle_address_from_oracle_should_not_work =
    let (_, betting_contract, betting_taddress, elon, jeff, _, _, _) = Bootstrap.bootstrap() in
    let () = Assert.oracle betting_taddress jeff in

    let ret = Helper.trsc_change_oracle_address(betting_contract, jeff, elon) in
    let () = Assert.string_failure ret Errors.not_manager in
    let () = Assert.oracle betting_taddress jeff in
    "OK"

let test_change_oracle_address_from_unauthorized_address_should_not_work =
    let (_, betting_contract, betting_taddress, _, jeff, alice, _, _) = Bootstrap.bootstrap() in
    let () = Assert.oracle betting_taddress jeff in

    let ret = Helper.trsc_change_oracle_address(betting_contract, alice, alice) in
    let () = Assert.string_failure ret Errors.not_manager in
    let () = Assert.oracle betting_taddress jeff in
    "OK"
