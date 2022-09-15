#import "../../contracts/cameligo/betting/main.mligo" "Betting"
#import "../../contracts/cameligo/betting/types.mligo" "Types"
#import "helpers/bootstrap.mligo" "Bootstrap"
#import "helpers/helper.mligo" "Helper"
#import "helpers/assert.mligo" "Assert"
#import "helpers/events.mligo" "Events"
#import "helpers/log.mligo" "Log"

let () = Log.describe("[addEvent] test suite")

let test_failure_add_event_unauthorized =
    let (_betting_address, betting_contract, betting_taddress, _elon, _jeff, alice, _, _) = Bootstrap.bootstrap() in
    let () = Assert.assert_eventsMap betting_taddress Helper.empty_map in
    // Adding an Event from unauthorized address
    let result = Helper.trsc_add_event (betting_contract, alice, Events.eventype_to_addeventparam(Events.primary_event)) in
    let () = Assert.string_failure result Betting.Errors.not_manager_nor_oracle in 
    Assert.assert_eventsMap betting_taddress Helper.empty_map

let test_success_add_event_by_manager =
    let (_betting_address, betting_contract, betting_taddress, elon, _jeff, _alice, _, _) = Bootstrap.bootstrap() in
    let () = Assert.assert_eventsMap betting_taddress Helper.empty_map in
    // Adding an Event from Manager
    let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
    Assert.assert_eventsMap betting_taddress Helper.one_event_map 

let test_success_add_event_by_oracle =
    let (_betting_address, betting_contract, betting_taddress, _elon, jeff, _alice, _, _) = Bootstrap.bootstrap() in
    let () = Assert.assert_eventsMap betting_taddress Helper.empty_map in
    // Adding an Event from Oracle
    let () = Helper.trsc_add_event_success (betting_contract, jeff, Events.eventype_to_addeventparam(Events.primary_event)) in
    Assert.assert_eventsMap betting_taddress Helper.one_event_map

let test_success_add_two_events_by_manager_and_oracle =
    let (_betting_address, betting_contract, betting_taddress, elon, jeff, _alice, _, _) = Bootstrap.bootstrap() in
    let () = Assert.assert_eventsMap betting_taddress Helper.empty_map in
    // Adding an Event from Manager
    let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
    let () = Assert.assert_eventsMap betting_taddress Helper.one_event_map in
    // Adding an Event from Oracle
    let () = Helper.trsc_add_event_success (betting_contract, jeff, Events.eventype_to_addeventparam(Events.primary_event)) in
    Assert.assert_eventsMap betting_taddress Helper.double_event_map

