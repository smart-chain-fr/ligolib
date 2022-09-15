#import "../../contracts/cameligo/betting/main.mligo" "Betting"
#import "../../contracts/cameligo/betting/types.mligo" "Types"
#import "helpers/bootstrap.mligo" "Bootstrap"
#import "helpers/helper.mligo" "Helper"
#import "helpers/assert.mligo" "Assert"
#import "helpers/events.mligo" "Events"
#import "helpers/log.mligo" "Log"

// let () = Test.log("___ TEST updateEvent STARTED ___")
let () = Log.describe("[updateEvent] test suite")

let updated_eventMap : (nat, Types.event_type) big_map = Big_map.literal [
    (0n, Events.secondary_event)
    ]

let test_success_update_event =
    let (_betting_address, betting_contract, betting_taddress, elon, jeff, _alice, _, _) = Bootstrap.bootstrap() in
    let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
    // Updating the first Event from Manager
    let () = Helper.trsc_update_event_success (betting_contract, elon, 0n, Events.secondary_event) in
    let () = Assert.assert_eventsMap betting_taddress updated_eventMap in
    // Updating the first Event from Oracle
    let () = Helper.trsc_update_event_success (betting_contract, jeff, 0n, Events.primary_event) in
    Assert.assert_eventsMap betting_taddress Helper.one_event_map

let test_failure_update_event_unauthorized_address =
    let (_betting_address, betting_contract, betting_taddress, elon, _jeff, alice, _, _) = Bootstrap.bootstrap() in
    let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
    // Updating the first Event from unauthorized address
    let result = Helper.trsc_update_event (betting_contract, alice, 0n, Events.secondary_event) in
    let () = Assert.string_failure result Betting.Errors.not_manager_nor_oracle in
    Assert.assert_eventsMap betting_taddress Helper.one_event_map

let test_success_update_three_events =
    let (_betting_address, betting_contract, betting_taddress, elon, jeff, _alice, _, _) = Bootstrap.bootstrap() in
    let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
    let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
    let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
    let () = Assert.assert_eventsMap betting_taddress Helper.three_event_map in

    // Updating the third Event from Manager
    let () = Helper.trsc_update_event_success (betting_contract, elon, 1n, Events.primary_event) in
    let () = Assert.assert_eventsMap betting_taddress Helper.three_event_map in

    // Updating the third Event from Oracle
    let () = Helper.trsc_update_event_success (betting_contract, jeff, 1n, Events.primary_event) in
    Assert.assert_eventsMap betting_taddress Helper.three_event_map
