#import "../../contracts/cameligo/betting/main.mligo" "BETTING"
#import "../../contracts/cameligo/betting/types.mligo" "TYPES"
#import "helpers/bootstrap.mligo" "BOOTSTRAP"
#import "helpers/helper.mligo" "HELPER"
#import "helpers/assert.mligo" "ASSERT"

let () = Test.log("___ TEST AddBet STARTED ___")

let (betting_contract, betting_taddress, elon, jeff, alice, _, _) = BOOTSTRAP.bootstrap

let () = Test.log("-> Initial Storage :")
let () = Test.log(betting_contract, betting_taddress, elon, jeff)

let () = ASSERT.assert_eventsMap betting_taddress HELPER.emptyMap

let () = Test.log("-> Adding an Event from Manager address")
let () = HELPER.trscAddEvent (betting_contract, elon, BOOTSTRAP.primaryEvent)
let () = ASSERT.assert_eventsMap betting_taddress HELPER.oneEventMap

let () = Test.log("-> Adding a Bet to an existing event from Manager")
let () = HELPER.trscAddBet (betting_contract, elon, 0n, (true : bool), 2tez)
let () = Test.log(HELPER.printStorage(betting_taddress))

// let () = ASSERT.assert_eventsMap betting_taddress HELPER.emptyMap

// let () = Test.log("-> Adding a Bet to an existing event from Oracle")
// let () = HELPER.trscAddEvent (betting_contract, elon, BOOTSTRAP.primaryEvent)
// let () = ASSERT.assert_eventsMap betting_taddress HELPER.emptyMap

// let () = Test.log("-> Adding a Bet to an existing event from User to TeamOne")
// let () = HELPER.trscAddEvent (betting_contract, elon, BOOTSTRAP.primaryEvent)
// let () = ASSERT.assert_eventsMap betting_taddress HELPER.emptyMap

// let () = Test.log("-> Adding a Bet to an existing event from User to TeamTwo")
// let () = HELPER.trscAddEvent (betting_contract, elon, BOOTSTRAP.primaryEvent)
// let () = ASSERT.assert_eventsMap betting_taddress HELPER.emptyMap

// let () = Test.log("-> Adding a Bet to an existing event from User to TeamTwo")
// let () = HELPER.trscAddEvent (betting_contract, elon, BOOTSTRAP.primaryEvent)
// let () = ASSERT.assert_eventsMap betting_taddress HELPER.emptyMap

// let () = Test.log("___ TEST AddBet ENDED ___")