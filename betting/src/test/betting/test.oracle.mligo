#import "../../contracts/cameligo/betting/main.mligo" "BETTING"
#import "helpers/bootstrap.mligo" "BOOTSTRAP"
#import "helpers/helper.mligo" "HELPER"
#import "helpers/assert.mligo" "ASSERT"
#import "helpers/log.mligo" "Log"

// let () = Test.log("___ TEST ChangeOracleAddress STARTED ___")
let () = Log.describe("[ChangeOracleAddress] test suite")

let test_change_oracle_address =
    let (_betting_address, betting_contract, betting_taddress, elon, jeff, _, _, _) = BOOTSTRAP.bootstrap() in
    let () = ASSERT.assert_oracle betting_taddress jeff in

    // Changing Oracle of the contract from original Manager
    let () = HELPER.trscChangeOracleAddress_success(betting_contract, elon, elon) in
    let () = ASSERT.assert_oracle betting_taddress elon in

    // Changing Oracle of the contract to current Oracle
    let result = HELPER.trscChangeOracleAddress(betting_contract, elon, elon) in
    let () = ASSERT.string_failure result BETTING.ERRORS.same_previous_oracle_address in
    let () = ASSERT.assert_oracle betting_taddress elon in

    // Changing Oracle of the contract to original Oracle
    let () = HELPER.trscChangeOracleAddress_success(betting_contract, elon, jeff) in
    ASSERT.assert_oracle betting_taddress jeff

let test_failure_change_oracle_address =
    let (_betting_address, betting_contract, betting_taddress, elon, jeff, _, _, _) = BOOTSTRAP.bootstrap() in
    // Changing Manager of the contract from unauthorized address
    let result = HELPER.trscChangeOracleAddress (betting_contract, jeff, elon) in
    let () = ASSERT.string_failure result BETTING.ERRORS.not_manager in
    ASSERT.assert_oracle betting_taddress jeff

// let () = Test.log("___ TEST ChangeOracleAddress ENDED ___")