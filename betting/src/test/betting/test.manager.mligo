#import "../../contracts/cameligo/betting/main.mligo" "BETTING"
#import "helpers/bootstrap.mligo" "BOOTSTRAP"
#import "helpers/helper.mligo" "HELPER"
#import "helpers/assert.mligo" "ASSERT"
#import "helpers/log.mligo" "Log"

// let () = Test.log("___ TEST ChangeManager STARTED ___")
let () = Log.describe("[ChangeManager] test suite")

let test_failure_change_manager_unauthorized =
    // Changing Manager of the contract from unauthorized address
    let (_betting_address, betting_contract, betting_taddress, elon, jeff, _, _, _) = BOOTSTRAP.bootstrap() in
    //let () = Test.log(betting_contract, betting_taddress, elon, jeff) in
    let () = ASSERT.assert_manager betting_taddress elon in
    let result = HELPER.trscChangeManager (betting_contract, jeff, jeff) in
    let () = ASSERT.string_failure result BETTING.ERRORS.not_manager in
    ASSERT.assert_manager betting_taddress elon

let test_success_change_manager_authorized =
    // Changing Manager of the contract from original Manager, and back to 
    let (_betting_address, betting_contract, betting_taddress, elon, jeff, _, _, _) = BOOTSTRAP.bootstrap() in
    //let () = Test.log(betting_contract, betting_taddress, elon, jeff) in
    let () = ASSERT.assert_manager betting_taddress elon in
    let () = HELPER.trscChangeManager_success (betting_contract, elon, jeff) in
    let () = ASSERT.assert_manager betting_taddress jeff in
    // Changing Manager of the contract from current Manager, back to original Manager 
    let () = HELPER.trscChangeManager_success (betting_contract, jeff, elon) in
    ASSERT.assert_manager betting_taddress elon
