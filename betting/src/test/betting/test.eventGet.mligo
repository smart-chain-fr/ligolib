#import "../../contracts/cameligo/betting/main.mligo" "BETTING"
#import "../../contracts/cameligo/betting/types.mligo" "TYPES"
#import "helpers/bootstrap.mligo" "BOOTSTRAP"
#import "helpers/helper.mligo" "HELPER"
#import "helpers/assert.mligo" "ASSERT"

let () = Test.log("___ TEST getEvent STARTED ___")

let (betting_contract, betting_taddress, elon, jeff, _, _, _) = BOOTSTRAP.bootstrap()
let (callback_contract, callback_taddr, callback_addr) = BOOTSTRAP.bootstrap_callback
let () = HELPER.trscAddEvent (betting_contract, elon, BOOTSTRAP.eventype_to_addeventparam(BOOTSTRAP.primaryEvent))
let () = ASSERT.assert_eventsMap betting_taddress HELPER.oneEventMap

let () = HELPER.trscGetEvent (betting_contract, elon, callback_addr, 0n)

let () = Test.log("___ TEST getEvent ENDED ___")