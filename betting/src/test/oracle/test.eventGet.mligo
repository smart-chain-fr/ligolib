#import "../../contracts/cameligo/oracle/main.mligo" "ORACLE"
#import "../../contracts/cameligo/oracle/types.mligo" "TYPES"
#import "helpers/bootstrap.mligo" "BOOTSTRAP"
#import "helpers/helper.mligo" "HELPER"
#import "helpers/assert.mligo" "ASSERT"

let () = Test.log("___ TEST getEvent STARTED ___")

let (oracle_contract, oracle_taddress, elon, jeff, _, _, _) = BOOTSTRAP.bootstrap
let (callback_contract, callback_taddr, callback_addr) = BOOTSTRAP.bootstrap_callback
let () = HELPER.trscAddEvent (oracle_contract, elon, BOOTSTRAP.primaryEvent)
let () = ASSERT.assert_eventsMap oracle_taddress HELPER.oneEventMap

let () = HELPER.trscGetEvent (oracle_contract, elon, callback_addr, 1n)

let () = Test.log("___ TEST getEvent ENDED ___")