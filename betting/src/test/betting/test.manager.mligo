#import "../../contracts/cameligo/betting/main.mligo" "Betting"
#import "helpers/bootstrap.mligo" "Bootstrap"
#import "helpers/helper.mligo" "Helper"
#import "helpers/assert.mligo" "Assert"
#import "helpers/log.mligo" "Log"

// let () = Test.log("___ TEST ChangeManager STARTED ___")
let () = Log.describe("[ChangeManager] test suite")

let test_failure_change_manager_unauthorized =
    // Changing Manager of the contract from unauthorized address
    let (_betting_address, betting_contract, betting_taddress, elon, jeff, _, _, _) = Bootstrap.bootstrap() in
    //let () = Test.log(betting_contract, betting_taddress, elon, jeff) in
    let () = Assert.assert_manager betting_taddress elon in
    let result = Helper.trsc_change_manager (betting_contract, jeff, jeff) in
    let () = Assert.string_failure result Betting.Errors.not_manager in
    Assert.assert_manager betting_taddress elon

let test_success_change_manager_authorized =
    // Changing Manager of the contract from original Manager, and back to 
    let (_betting_address, betting_contract, betting_taddress, elon, jeff, _, _, _) = Bootstrap.bootstrap() in
    //let () = Test.log(betting_contract, betting_taddress, elon, jeff) in
    let () = Assert.assert_manager betting_taddress elon in
    let () = Helper.trsc_change_manager_success (betting_contract, elon, jeff) in
    let () = Assert.assert_manager betting_taddress jeff in
    // Changing Manager of the contract from current Manager, back to original Manager 
    let () = Helper.trsc_change_manager_success (betting_contract, jeff, elon) in
    Assert.assert_manager betting_taddress elon
