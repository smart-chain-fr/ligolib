#import "../../contracts/cameligo/betting/main.mligo" "BETTING"
#import "helpers/bootstrap.mligo" "BOOTSTRAP"
#import "helpers/helper.mligo" "HELPER"
#import "helpers/assert.mligo" "ASSERT"

let () = Test.log("___ TEST ChangeOracleAddress STARTED ___")

let (betting_contract, betting_taddress, elon, jeff, _, _, _) = BOOTSTRAP.bootstrap

let () = Test.log("-> Initial Storage :")
let () = Test.log(betting_contract, betting_taddress, elon, jeff)

let () = Test.log("-> Initial Storage assert :")
let () = ASSERT.assert_BETTING betting_taddress jeff

let () = Test.log("-> Changing BETTING of the contract from original Manager")
let () = HELPER.trscChangeOracleAddress(betting_contract, elon, elon)
let () = ASSERT.assert_BETTING betting_taddress elon

let () = Test.log("-> Changing BETTING of the contract to current BETTING")
let () = HELPER.trscChangeOracleAddress(betting_contract, elon, elon)
let () = ASSERT.assert_BETTING betting_taddress elon

let () = Test.log("-> Changing BETTING of the contract to original BETTING")
let () = HELPER.trscChangeOracleAddress(betting_contract, elon, jeff)
let () = ASSERT.assert_BETTING betting_taddress jeff

let () = Test.log("-> Changing Manager of the contract from unauthorized address")
let () = HELPER.trscChangeOracleAddress (betting_contract, jeff, elon)
let () = ASSERT.assert_BETTING betting_taddress jeff

let () = Test.log("___ TEST ChangeOracleAddress ENDED ___")