#import "../../contracts/cameligo/oracle/main.mligo" "ORACLE"
#import "../../contracts/cameligo/oracle/types.mligo" "TYPES"
#import "helpers/bootstrap.mligo" "BOOTSTRAP"
#import "helpers/helper.mligo" "HELPER"
#import "helpers/assert.mligo" "ASSERT"
#import "helpers/log.mligo" "Log"


//let () = Test.log("___ TEST getEvent STARTED ___")
let () = Log.describe("[getEvent] test suite")

let test_callback_contract =
    let (oracle_contract, oracle_taddress, elon, _jeff, _, _, _) = BOOTSTRAP.bootstrap_oracle() in 
    let originated_oracle_callback = BOOTSTRAP.bootstrap_oracle_callback() in
    let _ret = HELPER.trscAddEvent (oracle_contract, elon, BOOTSTRAP.primaryEvent) in
    let () = ASSERT.assert_eventsMap oracle_taddress HELPER.oneEventMap in

    let ret = HELPER.trscGetEvent (oracle_contract, elon, originated_oracle_callback.addr, 0n) in
    let () = ASSERT.tx_success (ret) in

    ASSERT.assert_event originated_oracle_callback.taddr BOOTSTRAP.primaryEvent

let () = Test.log("___ TEST getEvent ENDED ___")