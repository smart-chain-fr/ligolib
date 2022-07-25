#import "../../contracts/cameligo/betting/main.mligo" "ORACLE"
#import "../../contracts/cameligo/betting/types.mligo" "TYPES"
#import "./helpers/bootstrap.mligo" "BOOTSTRAP"
#import "./helpers/helper.mligo" "HELPER"
#import "./helpers/assert.mligo" "ASSERT"

let () = Test.log("___ TEST addEvent STARTED ___")

let emptyMap : (nat, TYPES.eventType) map = (Map.empty : (nat, TYPES.eventType) map)

let (betting_contract, betting_taddress, elon, jeff, alice, _, _) = BOOTSTRAP.bootstrap

let () = Test.log("-> Initial Storage :")
let () = Test.log(betting_contract, betting_taddress, elon, jeff)

let () = ASSERT.assert_eventsMap betting_taddress emptyMap

let () = Test.log("-> Adding an Event from unauthorized address")
let () = HELPER.trscAddEvent (betting_contract, alice, BOOTSTRAP.primaryEvent)
let () = ASSERT.assert_eventsMap betting_taddress emptyMap

let oneEventMap : (nat, TYPES.eventType) map = Map.literal [
    (1n, BOOTSTRAP.primaryEvent)
    ]

let () = Test.log("-> Adding an Event from Manager")
let () = HELPER.trscAddEvent (betting_contract, elon, BOOTSTRAP.primaryEvent)
let () = ASSERT.assert_eventsMap betting_taddress oneEventMap

let doubleEventMap : (nat, TYPES.eventType) map = Map.literal [
    (1n, BOOTSTRAP.primaryEvent);
    (2n, BOOTSTRAP.primaryEvent)
    ]

let () = Test.log("-> Adding an Event from Oracle")
let () = HELPER.trscAddEvent (betting_contract, jeff, BOOTSTRAP.primaryEvent)
let () = ASSERT.assert_eventsMap betting_taddress doubleEventMap

// let () = Test.log("-> Changing Manager of the contract from original Manager")
// let () = HELPER.trscAddEvent (betting_contract, elon, jeff)
// let () = ASSERT.assert_manager betting_taddress jeff

// let () = Test.log("-> Changing Manager of the contract from the current Manager")
// let () = HELPER.trscAddEvent (betting_contract, jeff, elon)
// let () = ASSERT.assert_manager betting_taddress elon

(* OK : Transferring 100 from Alice to a random contract *)
// let test_transfer_to_contract (_ant_ctr : ANTI.parameter contract)(_alice : address)(_tsfr_amount : nat) =
//     let () = Test.log("--> test_transfer_to_contract : Transferring 100 from Alice to a random contract") in
//     let result : test_exec_result = ANTI_HELPER.transfer(_ant_ctr, _alice, ANTI_HELPER.base_config.random_contract_address, _tsfr_amount) in
//     let () = ASSERT.tx_success result in
//     let () = ANTI_HELPER.assert_transfer_contract (ant_addr, _alice, ANTI_HELPER.base_config.random_contract_address, ANTI_HELPER.base_config.init_token_balance, _tsfr_amount) in
//     let () = ANTI_HELPER.assert_burn_address_balance (ant_addr, 0n) in
//     let () = ANTI_HELPER.assert_reserve_address_balance (ant_addr, 0n) in
//     ()

// let () = test_transfer_to_contract ant_ctr alice 100n

let () = Test.log("___ TEST addEvent ENDED ___")