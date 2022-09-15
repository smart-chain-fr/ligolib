#import "../../contracts/cameligo/betting/main.mligo" "Betting"
#import "helpers/bootstrap.mligo" "Bootstrap"
#import "helpers/helper.mligo" "Helper"
#import "helpers/assert.mligo" "Assert"
#import "helpers/log.mligo" "Log"

let () = Log.describe("[SwitchPause] test suite")

let test_success_switch_pause_by_manager =
    // Boostrapping contract
    let (_betting_address, betting_contract, betting_taddress, elon, _jeff, _, _, _) = Bootstrap.bootstrap() in
    // Initial Storage
    //let () = Test.log(betting_contract, betting_taddress, elon, jeff) in

    // Initial Storage assert
    let () = Assert.assert_is_betting_paused betting_taddress false in

    // Switching Contract Betting state from Manager
    let () = Helper.trsc_switch_pauseBetting_success (betting_contract, elon) in
    let () = Assert.assert_is_betting_paused betting_taddress true in

    // Switching Contract Betting state from Manager
    let () = Helper.trsc_switch_pauseBetting_success (betting_contract, elon) in
    Assert.assert_is_betting_paused betting_taddress false

let test_failure_switch_pause_unauthorized =
    // Boostrapping contract
    let (_betting_address, betting_contract, betting_taddress, _elon, jeff, _, _, _) = Bootstrap.bootstrap() in
    let () = Assert.assert_is_betting_paused betting_taddress false in
    // Switching Contract Betting state from unauthorized address
    let result = Helper.trsc_switch_pauseBetting (betting_contract, jeff) in
    let () = Assert.string_failure result Betting.Errors.not_manager in
    Assert.assert_is_betting_paused betting_taddress false


let test_switch_pause_event_creation =
    let (_betting_address, betting_contract, betting_taddress, elon, jeff, _, _, _) = Bootstrap.bootstrap() in

    // Switching Contract Event state from Manager
    let () = Helper.trsc_switch_pauseEventCreation_success (betting_contract, elon) in
    let () = Assert.assert_is_event_creation_paused betting_taddress true in

    // Switching Contract Event state from Manager
    let () = Helper.trsc_switch_pauseEventCreation_success (betting_contract, elon) in
    let () = Assert.assert_is_event_creation_paused betting_taddress false in

    // Switching Contract Event state from unauthorized address
    let ret = Helper.trsc_switch_pauseEventCreation (betting_contract, jeff) in
    let () = Assert.string_failure ret Betting.Errors.not_manager in
    Assert.assert_is_event_creation_paused betting_taddress false