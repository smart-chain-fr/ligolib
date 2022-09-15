#import "helpers/bootstrap.mligo" "Bootstrap"
#import "helpers/helper.mligo" "Helper"
#import "helpers/assert.mligo" "Assert"
#import "helpers/log.mligo" "Log"

let () = Log.describe("[EventGet] test suite")

let test_callback_contract_should_work =
    let (oracle_contract, oracle_taddress, elon, _, _, _, _) = Bootstrap.bootstrap_oracle() in 
    let () = Assert.assert_eventsMap oracle_taddress Helper.empty_map in
    let originated_oracle_callback = Bootstrap.bootstrap_oracle_callback() in
    
    let () = Helper.trsc_add_event_success (oracle_contract, elon, Bootstrap.primary_event) in
    let () = Assert.assert_eventsMap oracle_taddress Helper.one_event_map in
    
    let () = Helper.trsc_get_event_success (oracle_contract, elon, originated_oracle_callback.addr, 0n) in
    let () = Assert.assert_event originated_oracle_callback.taddr Bootstrap.primary_event in
    "OK"