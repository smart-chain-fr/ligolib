#import "../../contracts/cameligo/betting/main.mligo" "BETTING"
#import "../../contracts/cameligo/betting/types.mligo" "TYPES"
#import "helpers/bootstrap.mligo" "BOOTSTRAP"
#import "helpers/helper.mligo" "HELPER"
#import "helpers/assert.mligo" "ASSERT"
#import "helpers/events.mligo" "EVENTS"
#import "helpers/log.mligo" "Log"

let () = Log.describe("[addEvent] test suite")

let test_failure_add_event_unauthorized =
    let (_betting_address, betting_contract, betting_taddress, _elon, _jeff, alice, _, _) = BOOTSTRAP.bootstrap() in
    let () = ASSERT.assert_eventsMap betting_taddress HELPER.emptyMap in
    // Adding an Event from unauthorized address
    let result = HELPER.trscAddEvent (betting_contract, alice, EVENTS.eventype_to_addeventparam(EVENTS.primaryEvent)) in
    let () = ASSERT.string_failure result BETTING.ERRORS.not_manager_nor_oracle in 
    ASSERT.assert_eventsMap betting_taddress HELPER.emptyMap

let test_success_add_event_by_manager =
    let (_betting_address, betting_contract, betting_taddress, elon, _jeff, _alice, _, _) = BOOTSTRAP.bootstrap() in
    let () = ASSERT.assert_eventsMap betting_taddress HELPER.emptyMap in
    // Adding an Event from Manager
    let () = HELPER.trscAddEvent_success (betting_contract, elon, EVENTS.eventype_to_addeventparam(EVENTS.primaryEvent)) in
    ASSERT.assert_eventsMap betting_taddress HELPER.oneEventMap 

let test_success_add_event_by_oracle =
    let (_betting_address, betting_contract, betting_taddress, _elon, jeff, _alice, _, _) = BOOTSTRAP.bootstrap() in
    let () = ASSERT.assert_eventsMap betting_taddress HELPER.emptyMap in
    // Adding an Event from Oracle
    let () = HELPER.trscAddEvent_success (betting_contract, jeff, EVENTS.eventype_to_addeventparam(EVENTS.primaryEvent)) in
    ASSERT.assert_eventsMap betting_taddress HELPER.oneEventMap

let test_success_add_two_events_by_manager_and_oracle =
    let (_betting_address, betting_contract, betting_taddress, elon, jeff, _alice, _, _) = BOOTSTRAP.bootstrap() in
    let () = ASSERT.assert_eventsMap betting_taddress HELPER.emptyMap in
    // Adding an Event from Manager
    let () = HELPER.trscAddEvent_success (betting_contract, elon, EVENTS.eventype_to_addeventparam(EVENTS.primaryEvent)) in
    let () = ASSERT.assert_eventsMap betting_taddress HELPER.oneEventMap in
    // Adding an Event from Oracle
    let () = HELPER.trscAddEvent_success (betting_contract, jeff, EVENTS.eventype_to_addeventparam(EVENTS.primaryEvent)) in
    ASSERT.assert_eventsMap betting_taddress HELPER.doubleEventMap

