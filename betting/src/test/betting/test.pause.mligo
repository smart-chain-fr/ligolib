#import "../../contracts/cameligo/betting/main.mligo" "BETTING"
#import "helpers/bootstrap.mligo" "BOOTSTRAP"
#import "helpers/helper.mligo" "HELPER"
#import "helpers/assert.mligo" "ASSERT"
#import "helpers/log.mligo" "Log"

let () = Log.describe("[SwitchPause] test suite")

let test_success_switch_pause_by_manager =
    // Boostrapping contract
    let (_betting_address, betting_contract, betting_taddress, elon, _jeff, _, _, _) = BOOTSTRAP.bootstrap() in
    // Initial Storage
    //let () = Test.log(betting_contract, betting_taddress, elon, jeff) in

    // Initial Storage assert
    let () = ASSERT.assert_isBettingPaused betting_taddress false in

    // Switching Contract Betting state from Manager
    let () = HELPER.trscSwitchPauseBetting_success (betting_contract, elon) in
    let () = ASSERT.assert_isBettingPaused betting_taddress true in

    // Switching Contract Betting state from Manager
    let () = HELPER.trscSwitchPauseBetting_success (betting_contract, elon) in
    ASSERT.assert_isBettingPaused betting_taddress false

let test_failure_switch_pause_unauthorized =
    // Boostrapping contract
    let (_betting_address, betting_contract, betting_taddress, _elon, jeff, _, _, _) = BOOTSTRAP.bootstrap() in
    let () = ASSERT.assert_isBettingPaused betting_taddress false in
    // Switching Contract Betting state from unauthorized address
    let result = HELPER.trscSwitchPauseBetting (betting_contract, jeff) in
    let () = ASSERT.string_failure result BETTING.ERRORS.not_manager in
    ASSERT.assert_isBettingPaused betting_taddress false


let test_switch_pause_event_creation =
    let (_betting_address, betting_contract, betting_taddress, elon, jeff, _, _, _) = BOOTSTRAP.bootstrap() in

    // Switching Contract Event state from Manager
    let () = HELPER.trscSwitchPauseEventCreation_success (betting_contract, elon) in
    let () = ASSERT.assert_isEventCreationPaused betting_taddress true in

    // Switching Contract Event state from Manager
    let () = HELPER.trscSwitchPauseEventCreation_success (betting_contract, elon) in
    let () = ASSERT.assert_isEventCreationPaused betting_taddress false in

    // Switching Contract Event state from unauthorized address
    let ret = HELPER.trscSwitchPauseEventCreation (betting_contract, jeff) in
    let () = ASSERT.string_failure ret BETTING.ERRORS.not_manager in
    ASSERT.assert_isEventCreationPaused betting_taddress false