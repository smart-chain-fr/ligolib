#import "../../contracts/cameligo/betting/main.mligo" "BETTING"
#import "../../contracts/cameligo/betting/types.mligo" "TYPES"
#import "helpers/bootstrap.mligo" "BOOTSTRAP"
#import "helpers/helper.mligo" "HELPER"
#import "helpers/assert.mligo" "ASSERT"
#import "helpers/events.mligo" "EVENTS"
#import "helpers/log.mligo" "Log"

// let () = Test.log("___ TEST addEvent STARTED ___")
let () = Log.describe("[addEvent] test suite")

let test_add_event =
    let (betting_contract, betting_taddress, elon, jeff, alice, _, _) = BOOTSTRAP.bootstrap() in
    let () = ASSERT.assert_eventsMap betting_taddress HELPER.emptyMap in

    // Adding an Event from unauthorized address
    let result = HELPER.trscAddEvent (betting_contract, alice, EVENTS.eventype_to_addeventparam(EVENTS.primaryEvent)) in
    let () = ASSERT.string_failure result BETTING.ERRORS.not_manager_nor_oracle in 
    let () = ASSERT.assert_eventsMap betting_taddress HELPER.emptyMap in

    // Adding an Event from Manager
    let () = HELPER.trscAddEvent_success (betting_contract, elon, EVENTS.eventype_to_addeventparam(EVENTS.primaryEvent)) in
    let () = ASSERT.assert_eventsMap betting_taddress HELPER.oneEventMap in

    // Adding an Event from Oracle
    let () = HELPER.trscAddEvent_success (betting_contract, jeff, EVENTS.eventype_to_addeventparam(EVENTS.primaryEvent)) in
    ASSERT.assert_eventsMap betting_taddress HELPER.doubleEventMap

