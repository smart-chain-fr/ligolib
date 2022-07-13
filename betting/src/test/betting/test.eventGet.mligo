#import "../../contracts/cameligo/oracle/main.mligo" "ORACLE"
#import "../../contracts/cameligo/oracle/types.mligo" "TYPES"
#import "./helpers/bootstrap.mligo" "BOOTSTRAP"
#import "./helpers/helper.mligo" "HELPER"
#import "./helpers/assert.mligo" "ASSERT"

let () = Test.log("___ TEST getEvent STARTED ___")

let _oneEventMap : (nat, TYPES.eventType) map = Map.literal [
    (1n, BOOTSTRAP.secondaryEvent)
    ]

let (oracle_contract, oracle_taddress, elon, jeff, _, _, _) = BOOTSTRAP.bootstrap
let (callback_contract, callback_taddr, callback_addr) = BOOTSTRAP.bootstrap_callback
let () = HELPER.trscAddEvent (oracle_contract, elon, BOOTSTRAP.secondaryEvent)
let () = ASSERT.assert_eventsMap oracle_taddress _oneEventMap

let () = HELPER.trscGetEvent (oracle_contract, elon, callback_addr, 1n)

// let () = Test.get_storage(callback_taddr)

// let () = Test.log("-> Changing Manager of the contract from original Manager")
// let () = HELPER.trscAddEvent (oracle_contract, elon, jeff)
// let () = ASSERT.assert_manager oracle_taddress jeff

// let () = Test.log("-> Changing Manager of the contract from the current Manager")
// let () = HELPER.trscAddEvent (oracle_contract, jeff, elon)
// let () = ASSERT.assert_manager oracle_taddress elon

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

let () = Test.log("___ TEST getEvent ENDED ___")