#import "../../contracts/cameligo/betting/main.mligo" "ORACLE"
#import "./helpers/bootstrap.mligo" "BOOTSTRAP"
#import "./helpers/helper.mligo" "HELPER"
#import "./helpers/assert.mligo" "ASSERT"

let () = Test.log("___ TEST ChangeManager STARTED ___")

let (betting_contract, betting_taddress, elon, jeff, _, _, _) = BOOTSTRAP.bootstrap

let () = Test.log("-> Initial Storage :")
let () = Test.log(betting_contract, betting_taddress, elon, jeff)

let () = Test.log("-> Initial Storage assert :")
let () = ASSERT.assert_manager betting_taddress elon

let () = Test.log("-> Changing Manager of the contract from unauthorized address")
let () = HELPER.trscChangeManager (betting_contract, jeff, jeff)
let () = ASSERT.assert_manager betting_taddress elon

let () = Test.log("-> Changing Manager of the contract from original Manager")
let () = HELPER.trscChangeManager (betting_contract, elon, jeff)
let () = ASSERT.assert_manager betting_taddress jeff

let () = Test.log("-> Changing Manager of the contract from the current Manager")
let () = HELPER.trscChangeManager (betting_contract, jeff, elon)
let () = ASSERT.assert_manager betting_taddress elon

let () = Test.log("___ TEST ChangeManager ENDED ___")