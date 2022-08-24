#import "../../contracts/cameligo/betting/main.mligo" "BETTING"
#import "../../contracts/cameligo/betting/types.mligo" "TYPES"
#import "helpers/bootstrap.mligo" "BOOTSTRAP"
#import "helpers/helper.mligo" "HELPER"
#import "helpers/assert.mligo" "ASSERT"

let () = Test.log("___ TEST finalizeBet STARTED ___")

let (betting_contract, betting_taddress, elon, jeff, alice, _, _) = BOOTSTRAP.bootstrap

let () = Test.log("-> Initial Storage :")
let () = Test.log(betting_contract, betting_taddress, elon, jeff)

let () = ASSERT.assert_eventsMap betting_taddress HELPER.emptyMap

let () = Test.log("-> Adding an Event from unauthorized address")
let () = HELPER.trscAddEvent (betting_contract, alice, BOOTSTRAP.primaryEvent)
let () = ASSERT.assert_eventsMap betting_taddress HELPER.emptyMap


let () = Test.log("___ TEST finalizeBet ENDED ___")