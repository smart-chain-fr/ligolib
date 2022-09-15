#import "../../contracts/cameligo/betting/main.mligo" "Betting"
#import "helpers/bootstrap.mligo" "Bootstrap"
#import "helpers/helper.mligo" "Helper"
#import "helpers/assert.mligo" "Assert"
#import "helpers/log.mligo" "Log"

// let () = Test.log("___ TEST ChangeOracleAddress STARTED ___")
let () = Log.describe("[ChangeOracleAddress] test suite")

let test_change_oracle_address =
    let (_betting_address, betting_contract, betting_taddress, elon, jeff, _, _, _) = Bootstrap.bootstrap() in
    let () = Assert.assert_oracle betting_taddress jeff in

    // Changing Oracle of the contract from original Manager
    let () = Helper.trscChangeOracleAddress_success(betting_contract, elon, elon) in
    let () = Assert.assert_oracle betting_taddress elon in

    // Changing Oracle of the contract to current Oracle
    let result = Helper.trscChangeOracleAddress(betting_contract, elon, elon) in
    let () = Assert.string_failure result Betting.Errors.same_previous_oracle_address in
    let () = Assert.assert_oracle betting_taddress elon in

    // Changing Oracle of the contract to original Oracle
    let () = Helper.trscChangeOracleAddress_success(betting_contract, elon, jeff) in
    Assert.assert_oracle betting_taddress jeff

let test_failure_change_oracle_address =
    let (_betting_address, betting_contract, betting_taddress, elon, jeff, _, _, _) = Bootstrap.bootstrap() in
    // Changing Manager of the contract from unauthorized address
    let result = Helper.trscChangeOracleAddress (betting_contract, jeff, elon) in
    let () = Assert.string_failure result Betting.Errors.not_manager in
    Assert.assert_oracle betting_taddress jeff

// let () = Test.log("___ TEST ChangeOracleAddress ENDED ___")