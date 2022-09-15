#import "../../contracts/cameligo/betting/main.mligo" "Betting"
#import "helpers/bootstrap.mligo" "Bootstrap"
#import "helpers/helper.mligo" "Helper"
#import "helpers/assert.mligo" "Assert"
#import "helpers/log.mligo" "Log"

let () = Log.describe("[ChangeManager] test suite")

let test_change_manager_from_manager_should_work =
    let (_betting_address, betting_contract, betting_taddress, elon, jeff, _, _, _) = Bootstrap.bootstrap() in
    let () = Assert.assert_manager betting_taddress elon in
    let () = Helper.trsc_change_manager_success (betting_contract, elon, jeff) in
    let () = Assert.assert_manager betting_taddress jeff in
    let () = Helper.trsc_change_manager_success (betting_contract, jeff, elon) in
    let () = Assert.assert_manager betting_taddress elon in
    "OK"

let test_change_manager_from_unauthorized_address_should_not_work =
    let (_betting_address, betting_contract, betting_taddress, elon, jeff, _, _, _) = Bootstrap.bootstrap() in
    let () = Assert.assert_manager betting_taddress elon in
    let result = Helper.trsc_change_manager (betting_contract, jeff, jeff) in
    let () = Assert.string_failure result Betting.Errors.not_manager in
    let () = Assert.assert_manager betting_taddress elon in
    "OK"
