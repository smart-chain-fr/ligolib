#import "../../contracts/cameligo/betting/main.mligo" "BETTING"
#import "../../contracts/cameligo/betting/types.mligo" "TYPES"
#import "helpers/bootstrap.mligo" "BOOTSTRAP"
#import "helpers/helper.mligo" "HELPER"
#import "helpers/assert.mligo" "ASSERT"
#import "helpers/events.mligo" "EVENTS"
#import "helpers/log.mligo" "Log"

// let () = Test.log("___ TEST getEvent STARTED ___")

let () = Log.describe("[getEvent] test suite")

let test_get_event =
    let (betting_address, betting_contract, betting_taddress, elon, _jeff, _, _, _) = BOOTSTRAP.bootstrap() in
    //let (callback_contract, callback_taddr, callback_addr)
    let originated_betting_callback = BOOTSTRAP.bootstrap_betting_callback(betting_address) in 
    let () = HELPER.trscAddEvent_success (betting_contract, elon, EVENTS.eventype_to_addeventparam(EVENTS.primaryEvent))in
    let () = ASSERT.assert_eventsMap betting_taddress HELPER.oneEventMap in
    let ret = HELPER.trscGetEvent (betting_contract, elon, originated_betting_callback.addr, 0n) in
    let () = ASSERT.tx_success (ret) in
    ASSERT.assert_event originated_betting_callback.taddr EVENTS.primaryEvent

// let () = Test.log("___ TEST getEvent ENDED ___")
