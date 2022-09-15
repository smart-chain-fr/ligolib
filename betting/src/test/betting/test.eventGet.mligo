#import "../../contracts/cameligo/betting/main.mligo" "Betting"
#import "../../contracts/cameligo/betting/types.mligo" "Types"
#import "helpers/bootstrap.mligo" "Bootstrap"
#import "helpers/helper.mligo" "Helper"
#import "helpers/assert.mligo" "Assert"
#import "helpers/events.mligo" "Events"
#import "helpers/log.mligo" "Log"

let () = Log.describe("[EventGet] test suite") in

let test_get_event =
    let (betting_address, betting_contract, betting_taddress, elon, _jeff, _, _, _) = Bootstrap.bootstrap() in
    let originated_betting_callback = Bootstrap.bootstrap_betting_callback(betting_address) in 
    let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event))in
    let () = Assert.assert_eventsMap betting_taddress Helper.one_event_map in
    let () = Helper.trsc_get_event_success (betting_contract, elon, originated_betting_callback.addr, 0n) in
    Assert.assert_event originated_betting_callback.taddr Events.primary_event