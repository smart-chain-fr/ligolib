#import "../../contracts/cameligo/betting/main.mligo" "BETTING"
#import "../../contracts/cameligo/betting/types.mligo" "TYPES"
#import "helpers/bootstrap.mligo" "BOOTSTRAP"
#import "helpers/helper.mligo" "HELPER"
#import "helpers/assert.mligo" "ASSERT"
#import "helpers/events.mligo" "EVENTS"
#import "helpers/log.mligo" "Log"

// let () = Test.log("___ TEST updateEvent STARTED ___")
let () = Log.describe("[updateEvent] test suite")

let updatedEventMap : (nat, TYPES.event_type) big_map = Big_map.literal [
    (0n, EVENTS.secondaryEvent)
    ]

let test_success_update_event =
    let (_betting_address, betting_contract, betting_taddress, elon, jeff, _alice, _, _) = BOOTSTRAP.bootstrap() in
    let () = HELPER.trscAddEvent_success (betting_contract, elon, EVENTS.eventype_to_addeventparam(EVENTS.primaryEvent)) in
    // Updating the first Event from Manager
    let () = HELPER.trscUpdateEvent_success (betting_contract, elon, 0n, EVENTS.secondaryEvent) in
    let () = ASSERT.assert_eventsMap betting_taddress updatedEventMap in
    // Updating the first Event from Oracle
    let () = HELPER.trscUpdateEvent_success (betting_contract, jeff, 0n, EVENTS.primaryEvent) in
    ASSERT.assert_eventsMap betting_taddress HELPER.oneEventMap

let test_failure_update_event_unauthorized_address =
    let (_betting_address, betting_contract, betting_taddress, elon, _jeff, alice, _, _) = BOOTSTRAP.bootstrap() in
    let () = HELPER.trscAddEvent_success (betting_contract, elon, EVENTS.eventype_to_addeventparam(EVENTS.primaryEvent)) in
    // Updating the first Event from unauthorized address
    let result = HELPER.trscUpdateEvent (betting_contract, alice, 0n, EVENTS.secondaryEvent) in
    let () = ASSERT.string_failure result BETTING.ERRORS.not_manager_nor_oracle in
    ASSERT.assert_eventsMap betting_taddress HELPER.oneEventMap

let test_success_update_three_events =
    let (_betting_address, betting_contract, betting_taddress, elon, jeff, _alice, _, _) = BOOTSTRAP.bootstrap() in
    let () = HELPER.trscAddEvent_success (betting_contract, elon, EVENTS.eventype_to_addeventparam(EVENTS.primaryEvent)) in
    let () = HELPER.trscAddEvent_success (betting_contract, elon, EVENTS.eventype_to_addeventparam(EVENTS.primaryEvent)) in
    let () = HELPER.trscAddEvent_success (betting_contract, elon, EVENTS.eventype_to_addeventparam(EVENTS.primaryEvent)) in
    let () = ASSERT.assert_eventsMap betting_taddress HELPER.threeEventMap in

    // Updating the third Event from Manager
    let () = HELPER.trscUpdateEvent_success (betting_contract, elon, 1n, EVENTS.primaryEvent) in
    let () = ASSERT.assert_eventsMap betting_taddress HELPER.threeEventMap in

    // Updating the third Event from Oracle
    let () = HELPER.trscUpdateEvent_success (betting_contract, jeff, 1n, EVENTS.primaryEvent) in
    ASSERT.assert_eventsMap betting_taddress HELPER.threeEventMap
