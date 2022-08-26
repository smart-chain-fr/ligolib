#import "../../contracts/cameligo/oracle/main.mligo" "ORACLE"
#import "helpers/bootstrap.mligo" "BOOTSTRAP"
#import "helpers/helper.mligo" "HELPER"
#import "helpers/assert.mligo" "ASSERT"

let () = Test.log("___ TEST ChangeSigner STARTED ___")

let (oracle_contract, oracle_taddress, elon, jeff, alice, _, _) = BOOTSTRAP.bootstrap

let () = Test.log("-> Initial Storage :")
let () = Test.log(oracle_contract, oracle_taddress, elon, jeff)

let () = Test.log("-> Initial Storage assert :")
let () = ASSERT.assert_signer oracle_taddress jeff

let () = Test.log("-> Changing Signer of the contract from original Manager")
let () = HELPER.trscChangeSigner(oracle_contract, elon, elon)
let () = ASSERT.assert_signer oracle_taddress elon

let () = Test.log("-> Changing Signer of the contract to current Signer")
let () = HELPER.trscChangeSigner(oracle_contract, elon, elon)
let () = ASSERT.assert_signer oracle_taddress elon

let () = Test.log("-> Changing Signer of the contract to original Signer")
let () = HELPER.trscChangeSigner(oracle_contract, elon, jeff)
let () = ASSERT.assert_signer oracle_taddress jeff

let () = Test.log("-> Changing Manager of the contract from unauthorized address")
let () = HELPER.trscChangeSigner (oracle_contract, alice, alice)
let () = ASSERT.assert_signer oracle_taddress jeff

let () = Test.log("___ TEST ChangeSigner ENDED ___")