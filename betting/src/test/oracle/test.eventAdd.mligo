#import "../../contracts/cameligo/oracle/main.mligo" "ORACLE"
#import "../../contracts/cameligo/oracle/types.mligo" "TYPES"
#import "helpers/bootstrap.mligo" "BOOTSTRAP"
#import "helpers/helper.mligo" "HELPER"
#import "helpers/assert.mligo" "ASSERT"
#import "helpers/log.mligo" "Log"

// let () = Test.log("___ TEST addEvent STARTED ___")
let () = Log.describe("[addEvent] test suite")

let (oracle_contract, oracle_taddress, elon, jeff, alice, _, _) = BOOTSTRAP.bootstrap_oracle()

let () = Test.log("-> Initial Storage :")
let () = Test.log(oracle_contract, oracle_taddress, elon, jeff)

let () = ASSERT.assert_eventsMap oracle_taddress HELPER.emptyMap

let () = Test.log("-> Adding an Event from unauthorized address")
let () = HELPER.trscAddEvent (oracle_contract, alice, BOOTSTRAP.primaryEvent)
let () = ASSERT.assert_eventsMap oracle_taddress HELPER.emptyMap

let () = Test.log("-> Adding an Event from Manager")
let () = HELPER.trscAddEvent (oracle_contract, elon, BOOTSTRAP.primaryEvent)
let () = ASSERT.assert_eventsMap oracle_taddress HELPER.oneEventMap

let () = Test.log("-> Adding an Event from Signer")
let () = HELPER.trscAddEvent (oracle_contract, jeff, BOOTSTRAP.primaryEvent)
let () = ASSERT.assert_eventsMap oracle_taddress HELPER.doubleEventMap

let () = Test.log("___ TEST addEvent ENDED ___")