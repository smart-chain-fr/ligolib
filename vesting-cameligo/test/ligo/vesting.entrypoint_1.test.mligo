#import "./helpers/assert.mligo" "Assert"
#import "./bootstrap/bootstrap.mligo" "Bootstrap"
#import "./helpers/log.mligo" "Log"
#import "./helpers/vesting.mligo" "Vesting_helper"
#import "../../src/main.mligo" "Vesting"

let () = Log.describe("[Vesting] test suite")

let metadata_empty : (string, bytes) big_map = (Big_map.empty : (string, bytes) big_map)

let bootstrap () = Bootstrap.boot_vesting()

let test_success_entrypoint_1 =
    let (accounts, vesting) = bootstrap() in
    let (creator, operator) = accounts in
    let () = Test.set_source operator in
    let () = Vesting_helper.entrypoint_1_success({
        name = "collection_name";
    }, 0tez, vesting.contr) in
    "OK"
    //Vesting_helper.assert_owned_collections_size(vesting.taddr, creator, 1n)

let test_failure_entrypoint_1 =
    let (accounts, vesting) = bootstrap() in
    let (creator, operator) = accounts in
    let () = Test.set_source operator in
    let result = Vesting_helper.entrypoint_1({
        name = "collection_name";
    }, 0tez, vesting.contr) in
    Assert.string_failure result Vesting.Errors.not_admin
