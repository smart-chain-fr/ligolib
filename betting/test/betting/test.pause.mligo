#import "../../src/contracts/cameligo/betting/main.mligo" "Betting"
#import "helpers/bootstrap.mligo" "Bootstrap"
#import "helpers/helper.mligo" "Helper"
#import "helpers/assert.mligo" "Assert"
#import "helpers/log.mligo" "Log"

let () = Log.describe("[Betting - SwitchPause] test suite")

let test_success_switch_pause_by_manager =
    let (_betting_address, betting_contract, betting_taddress, elon, _jeff, _, _, _) = Bootstrap.bootstrap() in
    let () = Assert.is_betting_paused betting_taddress false in

    let () = Helper.trsc_switch_pauseBetting_success (betting_contract, elon) in
    let () = Assert.is_betting_paused betting_taddress true in

    let () = Helper.trsc_switch_pauseBetting_success (betting_contract, elon) in
    let () = Assert.is_betting_paused betting_taddress false in
    "OK"

let test_failure_switch_pause_unauthorized =
    let (_betting_address, betting_contract, betting_taddress, _elon, jeff, _, _, _) = Bootstrap.bootstrap() in
    let () = Assert.is_betting_paused betting_taddress false in

    let result = Helper.trsc_switch_pauseBetting (betting_contract, jeff) in
    let () = Assert.string_failure result Betting.Errors.not_manager in
    let () = Assert.is_betting_paused betting_taddress false in
    "OK"

let test_switch_pause_event_creation =
    let (_betting_address, betting_contract, betting_taddress, elon, jeff, _, _, _) = Bootstrap.bootstrap() in
    let () = Assert.is_betting_paused betting_taddress false in

    let () = Helper.trsc_switch_pauseEventCreation_success (betting_contract, elon) in
    let () = Assert.is_event_creation_paused betting_taddress true in

    let () = Helper.trsc_switch_pauseEventCreation_success (betting_contract, elon) in
    let () = Assert.is_event_creation_paused betting_taddress false in

    let ret = Helper.trsc_switch_pauseEventCreation (betting_contract, jeff) in
    let () = Assert.string_failure ret Betting.Errors.not_manager in
    let () = Assert.is_event_creation_paused betting_taddress false in
    "OK"