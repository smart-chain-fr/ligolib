#import "../../src/contracts/cameligo/betting/types.mligo" "Types"
#import "../../src/contracts/cameligo/betting/errors.mligo" "Errors"
#import "helpers/bootstrap.mligo" "Bootstrap"
#import "helpers/helper.mligo" "Helper"
#import "helpers/assert.mligo" "Assert"
#import "helpers/events.mligo" "Events"
#import "../common/log.mligo" "Log"

let () = Log.describe("[Betting - EventUpdate] test suite")

let updated_eventMap : (nat, Types.event_type) big_map = Big_map.literal [
    (0n, Events.secondary_event)
    ]

let test_update_event_from_manager_should_work =
    let (_betting_address, betting_contract, betting_taddress, elon, _, _, _, _) = Bootstrap.bootstrap() in
    let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
    // Updating the first Event from Manager
    let () = Helper.trsc_update_event_success (betting_contract, elon, 0n, Events.secondary_event) in
    let () = Assert.events_map betting_taddress updated_eventMap in
    "OK"

let test_update_event_from_oracle_should_work =
    let (_betting_address, betting_contract, betting_taddress, elon, jeff, _, _, _) = Bootstrap.bootstrap() in
    let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
    // Updating the first Event from Manager
    let () = Helper.trsc_update_event_success (betting_contract, jeff, 0n, Events.secondary_event) in
    let () = Assert.events_map betting_taddress updated_eventMap in
    "OK"

let test_update_event_from_unauthorized_address_should_not_work =
    let (_betting_address, betting_contract, betting_taddress, elon, _jeff, alice, _, _) = Bootstrap.bootstrap() in
    let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
    // Updating the first Event from unauthorized address
    let result = Helper.trsc_update_event (betting_contract, alice, 0n, Events.secondary_event) in
    let () = Assert.string_failure result Errors.not_manager_nor_oracle in
    let () = Assert.events_map betting_taddress Helper.one_event_map in
    "OK"

let test_update_third_event_from_manager_should_work =
    let (_betting_address, betting_contract, betting_taddress, elon, _, _, _, _) = Bootstrap.bootstrap() in
    let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
    let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
    let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
    let () = Assert.events_map betting_taddress Helper.three_event_map in

    // Updating the third Event from Manager
    let () = Helper.trsc_update_event_success (betting_contract, elon, 1n, Events.primary_event) in
    let () = Assert.events_map betting_taddress Helper.three_event_map in
    "OK"

let test_update_third_event_from_oracle_should_work =
    let (_betting_address, betting_contract, betting_taddress, elon, jeff, _, _, _) = Bootstrap.bootstrap() in
    let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
    let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
    let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
    let () = Assert.events_map betting_taddress Helper.three_event_map in

    // Updating the third Event from Oracle
    let () = Helper.trsc_update_event_success (betting_contract, jeff, 1n, Events.primary_event) in
    let () = Assert.events_map betting_taddress Helper.three_event_map in
    "OK"
