#import "../../src/contracts/cameligo/betting/errors.mligo" "Errors"
#import "helpers/bootstrap.mligo" "Bootstrap"
#import "helpers/helper.mligo" "Helper"
#import "helpers/assert.mligo" "Assert"
#import "helpers/events.mligo" "Events"
#import "helpers/log.mligo" "Log"

let () = Log.describe("[Betting - EventAdd] test suite")

let test_add_event_by_manager_should_work =
    let (_betting_address, betting_contract, betting_taddress, elon, _jeff, _alice, _, _) = Bootstrap.bootstrap() in
    let () = Assert.events_map betting_taddress Helper.empty_map in
    // Adding an Event from Manager
    let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
    let () = Assert.events_map betting_taddress Helper.one_event_map in
    "OK"

let test_add_event_by_oracle_should_work =
    let (_betting_address, betting_contract, betting_taddress, _elon, jeff, _alice, _, _) = Bootstrap.bootstrap() in
    let () = Assert.events_map betting_taddress Helper.empty_map in
    // Adding an Event from Oracle
    let () = Helper.trsc_add_event_success (betting_contract, jeff, Events.eventype_to_addeventparam(Events.primary_event)) in
    let () = Assert.events_map betting_taddress Helper.one_event_map in
    "OK"

let test_add_event_unauthorized_should_not_work =
    let (_betting_address, betting_contract, betting_taddress, _elon, _jeff, alice, _, _) = Bootstrap.bootstrap() in
    let () = Assert.events_map betting_taddress Helper.empty_map in
    // Adding an Event from unauthorized address
    let result = Helper.trsc_add_event (betting_contract, alice, Events.eventype_to_addeventparam(Events.primary_event)) in
    let () = Assert.string_failure result Errors.not_manager_nor_oracle in 
    let () = Assert.events_map betting_taddress Helper.empty_map in
    "OK"

let test_add_two_events_by_manager_and_oracle_should_work =
    let (_betting_address, betting_contract, betting_taddress, elon, jeff, _alice, _, _) = Bootstrap.bootstrap() in
    let () = Assert.events_map betting_taddress Helper.empty_map in
    // Adding an Event from Manager
    let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
    let () = Assert.events_map betting_taddress Helper.one_event_map in
    // Adding an Event from Oracle
    let () = Helper.trsc_add_event_success (betting_contract, jeff, Events.eventype_to_addeventparam(Events.primary_event)) in
    let () = Assert.events_map betting_taddress Helper.double_event_map in
    "OK"