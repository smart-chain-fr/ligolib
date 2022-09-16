#import "../../contracts/cameligo/betting/errors.mligo" "Errors"
#import "helpers/bootstrap.mligo" "Bootstrap"
#import "helpers/helper.mligo" "Helper"
#import "helpers/assert.mligo" "Assert"
#import "helpers/events.mligo" "Events"
#import "helpers/log.mligo" "Log"

let () = Log.describe("[EventGet] test suite")

let test_callback_contract_from_manager_should_work =
    let (betting_address, betting_contract, betting_taddress, elon, _, _, _, _) = Bootstrap.bootstrap() in
    let () = Assert.events_map betting_taddress Helper.empty_map in
    let originated_betting_callback = Bootstrap.bootstrap_betting_callback(betting_address) in 
    
    let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event))in
    let () = Assert.events_map betting_taddress Helper.one_event_map in
    
    let () = Helper.trsc_get_event_success (betting_contract, elon, originated_betting_callback.addr, 0n) in
    let () = Assert.event originated_betting_callback.taddr Events.primary_event in
    "OK"

let test_callback_contract_from_user_should_work =
    let (betting_address, betting_contract, betting_taddress, elon, _, alice, _, _) = Bootstrap.bootstrap() in
    let () = Assert.events_map betting_taddress Helper.empty_map in
    let originated_betting_callback = Bootstrap.bootstrap_betting_callback(betting_address) in 
    
    let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event))in
    let () = Assert.events_map betting_taddress Helper.one_event_map in
    
    let () = Helper.trsc_get_event_success (betting_contract, alice, originated_betting_callback.addr, 0n) in
    let () = Assert.event originated_betting_callback.taddr Events.primary_event in
    "OK"

let test_callback_contract_no_event_should_not_work =
    let (betting_address, betting_contract, betting_taddress, elon, _, _, _, _) = Bootstrap.bootstrap() in
    let () = Assert.events_map betting_taddress Helper.empty_map in
    let originated_betting_callback = Bootstrap.bootstrap_betting_callback(betting_address) in 
    
    let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event))in
    let () = Assert.events_map betting_taddress Helper.one_event_map in
    
    let ret = Helper.trsc_get_event (betting_contract, elon, originated_betting_callback.addr, 3n) in
    let () = Assert.string_failure ret Errors.no_event_id in
    "OK"