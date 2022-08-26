#import "../../contracts/cameligo/oracle/main.mligo" "ORACLE"
#import "../../contracts/cameligo/oracle/types.mligo" "TYPES"
#import "helpers/bootstrap.mligo" "BOOTSTRAP"
#import "helpers/helper.mligo" "HELPER"
#import "helpers/assert.mligo" "ASSERT"

let () = Test.log("___ TEST updateEvent STARTED ___")

let updatedEventMap : (nat, TYPES.event_type) map = Map.literal [
    (0n, BOOTSTRAP.secondaryEvent)
    ]

let (oracle_contract, oracle_taddress, elon, jeff, alice, _, _) = BOOTSTRAP.bootstrap
let () = HELPER.trscAddEvent (oracle_contract, elon, BOOTSTRAP.primaryEvent)

let () = Test.log("-> Updating the first Event from Manager")
let () = HELPER.trscUpdateEvent (oracle_contract, elon, 0n, BOOTSTRAP.secondaryEvent)
let () = ASSERT.assert_eventsMap oracle_taddress updatedEventMap

let () = Test.log("-> Updating the first Event from Signer")
let () = HELPER.trscUpdateEvent (oracle_contract, jeff, 0n, BOOTSTRAP.primaryEvent)
let () = ASSERT.assert_eventsMap oracle_taddress HELPER.oneEventMap

let () = Test.log("-> Updating the first Event from unauthorized address")
let () = HELPER.trscUpdateEvent (oracle_contract, alice, 0n, BOOTSTRAP.secondaryEvent)
let () = ASSERT.assert_eventsMap oracle_taddress HELPER.oneEventMap

let () = HELPER.trscAddEvent (oracle_contract, elon, BOOTSTRAP.primaryEvent)
let () = HELPER.trscAddEvent (oracle_contract, elon, BOOTSTRAP.primaryEvent)

let () = ASSERT.assert_eventsMap oracle_taddress HELPER.threeEventMap

let updatedThreeEventMap : (nat, TYPES.event_type) map = Map.literal [
    (0n, BOOTSTRAP.primaryEvent);
    (1n, BOOTSTRAP.primaryEvent);
    (2n, BOOTSTRAP.secondaryEvent);
    ]

let () = Test.log("-> Updating the third Event from Manager")
let () = HELPER.trscUpdateEvent (oracle_contract, elon, 2n, BOOTSTRAP.secondaryEvent)
let () = ASSERT.assert_eventsMap oracle_taddress updatedThreeEventMap

let () = Test.log("-> Updating the third Event from Signer")
let () = HELPER.trscUpdateEvent (oracle_contract, jeff, 2n, BOOTSTRAP.primaryEvent)
let () = ASSERT.assert_eventsMap oracle_taddress HELPER.threeEventMap

let () = Test.log("___ TEST updateEvent ENDED ___")