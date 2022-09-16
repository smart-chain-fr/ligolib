#import "../../contracts/cameligo/oracle/errors.mligo" "Errors"
#import "helpers/bootstrap.mligo" "Bootstrap"
#import "helpers/helper.mligo" "Helper"
#import "helpers/assert.mligo" "Assert"
#import "helpers/log.mligo" "Log"

let () = Log.describe("[EventGet] test suite")

let test_callback_contract_from_manager_should_work =
    let (oracle_contract, oracle_taddress, elon, _, _, _, _) = Bootstrap.bootstrap_oracle() in 
    let () = Assert.events_map oracle_taddress Helper.empty_map in
    let originated_oracle_callback = Bootstrap.bootstrap_oracle_callback() in
    
    let () = Helper.trsc_add_event_success (oracle_contract, elon, Bootstrap.primary_event) in
    let () = Assert.events_map oracle_taddress Helper.one_event_map in
    
    let () = Helper.trsc_get_event_success (oracle_contract, elon, originated_oracle_callback.addr, 0n) in
    let () = Assert.event originated_oracle_callback.taddr Bootstrap.primary_event in
    "OK"

let test_callback_contract_from_user_should_work =
    let (oracle_contract, oracle_taddress, elon, _, alice, _, _) = Bootstrap.bootstrap_oracle() in 
    let () = Assert.events_map oracle_taddress Helper.empty_map in
    let originated_oracle_callback = Bootstrap.bootstrap_oracle_callback() in
    
    let () = Helper.trsc_add_event_success (oracle_contract, elon, Bootstrap.primary_event) in
    let () = Assert.events_map oracle_taddress Helper.one_event_map in
    
    let () = Helper.trsc_get_event_success (oracle_contract, alice, originated_oracle_callback.addr, 0n) in
    let () = Assert.event originated_oracle_callback.taddr Bootstrap.primary_event in
    "OK"

let test_callback_contract_no_event_should_not_work =
    let (oracle_contract, oracle_taddress, elon, _, _, _, _) = Bootstrap.bootstrap_oracle() in 
    let () = Assert.events_map oracle_taddress Helper.empty_map in
    let originated_oracle_callback = Bootstrap.bootstrap_oracle_callback() in
    
    let () = Helper.trsc_add_event_success (oracle_contract, elon, Bootstrap.primary_event) in
    let () = Assert.events_map oracle_taddress Helper.one_event_map in
    
    let ret = Helper.trsc_get_event (oracle_contract, elon, originated_oracle_callback.addr, 3n) in
    let () = Assert.string_failure ret Errors.no_event_id in
    "OK"