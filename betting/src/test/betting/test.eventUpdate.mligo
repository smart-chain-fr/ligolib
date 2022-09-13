#import "../../contracts/cameligo/betting/main.mligo" "BETTING"
#import "../../contracts/cameligo/betting/types.mligo" "TYPES"
#import "helpers/bootstrap.mligo" "BOOTSTRAP"
#import "helpers/helper.mligo" "HELPER"
#import "helpers/assert.mligo" "ASSERT"
#import "helpers/events.mligo" "EVENTS"

let () = Test.log("___ TEST updateEvent STARTED ___")

let updatedEventMap : (nat, TYPES.event_type) big_map = Big_map.literal [
    (0n, EVENTS.secondaryEvent)
    ]

let (betting_contract, betting_taddress, elon, jeff, alice, _, _) = BOOTSTRAP.bootstrap()
let () = HELPER.trscAddEvent (betting_contract, elon, EVENTS.eventype_to_addeventparam(EVENTS.primaryEvent))

let () = Test.log("-> Updating the first Event from Manager")
let () = HELPER.trscUpdateEvent (betting_contract, elon, 0n, EVENTS.secondaryEvent)
let () = ASSERT.assert_eventsMap betting_taddress updatedEventMap

let () = Test.log("-> Updating the first Event from Oracle")
let () = HELPER.trscUpdateEvent (betting_contract, jeff, 0n, EVENTS.primaryEvent)
let () = ASSERT.assert_eventsMap betting_taddress HELPER.oneEventMap

let () = Test.log("-> Updating the first Event from unauthorized address")
let () = HELPER.trscUpdateEvent (betting_contract, alice, 0n, EVENTS.secondaryEvent)
let () = ASSERT.assert_eventsMap betting_taddress HELPER.oneEventMap

let () = HELPER.trscAddEvent (betting_contract, elon, EVENTS.eventype_to_addeventparam(EVENTS.primaryEvent))
let () = HELPER.trscAddEvent (betting_contract, elon, EVENTS.eventype_to_addeventparam(EVENTS.primaryEvent))

let () = ASSERT.assert_eventsMap betting_taddress HELPER.threeEventMap

let () = Test.log("-> Updating the third Event from Manager")
let () = HELPER.trscUpdateEvent (betting_contract, elon, 1n, EVENTS.primaryEvent)
let () = ASSERT.assert_eventsMap betting_taddress HELPER.threeEventMap

let () = Test.log("-> Updating the third Event from Oracle")
let () = HELPER.trscUpdateEvent (betting_contract, jeff, 1n, EVENTS.primaryEvent)
let () = ASSERT.assert_eventsMap betting_taddress HELPER.threeEventMap

let () = Test.log("___ TEST updateEvent ENDED ___")