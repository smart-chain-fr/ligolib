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
    let (betting_contract, betting_taddress, elon, _, _, _, _) = BOOTSTRAP.bootstrap() in
    let (_, _, callback_addr) = BOOTSTRAP.bootstrap_callback in 
    let () = HELPER.trscAddEvent_success (betting_contract, elon, EVENTS.eventype_to_addeventparam(EVENTS.primaryEvent))in
    let () = ASSERT.assert_eventsMap betting_taddress HELPER.oneEventMap in
    HELPER.trscGetEvent (betting_contract, elon, callback_addr, 0n)

// let () = Test.log("___ TEST getEvent ENDED ___")
