#import "../../contracts/cameligo/betting/main.mligo" "ORACLE"
#import "./helpers/bootstrap.mligo" "BOOTSTRAP"
#import "./helpers/helper.mligo" "HELPER"
#import "./helpers/assert.mligo" "ASSERT"

let () = Test.log("___ TEST SwitchPause STARTED ___")

let () = Test.log("-> Boostrapping contract")
let (betting_contract, betting_taddress, elon, jeff, _, _, _) = BOOTSTRAP.bootstrap

let () = Test.log("-> Initial Storage :")
let () = Test.log(betting_contract, betting_taddress, elon, jeff)

let () = Test.log("-> Initial Storage assert :")
let () = ASSERT.assert_ispaused betting_taddress false

let () = Test.log("-> Switching Contract state from Manager")
let () = HELPER.trscSwitchPause (betting_contract, elon)
let () = ASSERT.assert_ispaused betting_taddress true

let () = Test.log("-> Switching Contract state from Manager")
let () = HELPER.trscSwitchPause (betting_contract, elon)
let () = ASSERT.assert_ispaused betting_taddress false

let () = Test.log("-> Switching Contract state from unauthorized address")
let () = HELPER.trscSwitchPause (betting_contract, jeff)
let () = ASSERT.assert_ispaused betting_taddress false

let () = Test.log("___ TEST SwitchPause ENDED ___")