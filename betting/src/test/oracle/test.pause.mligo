#import "../../contracts/cameligo/oracle/main.mligo" "ORACLE"
#import "./helpers/bootstrap.mligo" "BOOTSTRAP"
#import "./helpers/helper.mligo" "HELPER"

let () = Test.log("___ TEST STARTED ___")

let (oracle_contract, oracle_taddress, elon, jeff, alice, bob, james) = BOOTSTRAP.bootstrap

let () = Test.log(oracle_contract, oracle_taddress, elon, jeff, alice, bob, james)

let () = Test.log(HELPER.get_storage(oracle_taddress))

let () = HELPER.trscSwitchPause (oracle_contract, elon)

let () = Test.log(HELPER.get_storage(oracle_taddress))

let () = HELPER.trscSwitchPause (oracle_contract, elon)

let () = Test.log(HELPER.get_storage(oracle_taddress))

let () = HELPER.trscSwitchPause (oracle_contract, elon)

let () = Test.log(HELPER.get_storage(oracle_taddress))

let () = HELPER.trscSwitchPause (oracle_contract, jeff)

let () = Test.log(HELPER.get_storage(oracle_taddress))

let () = HELPER.trscSwitchPause (oracle_contract, jeff)

let () = Test.log(HELPER.get_storage(oracle_taddress))

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

let () = Test.log("___ TEST ENDED ___")