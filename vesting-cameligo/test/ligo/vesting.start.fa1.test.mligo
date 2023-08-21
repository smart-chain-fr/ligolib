#import "./helpers/assert.mligo" "Assert"
#import "./bootstrap/bootstrap.mligo" "Bootstrap"
#import "./helpers/log.mligo" "Log"
#import "./helpers/vesting.mligo" "Vesting_helper"
#import "./helpers/fa1.mligo" "FA1_helper"
#import "../../src/main.mligo" "Vesting"

let () = Log.describe("[Vesting - Start - FA1] test suite")

let metadata_empty : (string, bytes) big_map = (Big_map.empty : (string, bytes) big_map)

let test_success_start_by_admin =
    let accounts = Bootstrap.boot_accounts(Vesting_helper.zero_timestamp) in
    let (admin, alice, bob) = accounts in
    let token_id = 0n in
    let fa1 = Bootstrap.boot_fa1(token_id, admin, 1000n) in
    let beneficiaries = Map.literal[(alice, 20n);(bob, 10n)] in
    let vesting = Bootstrap.boot_vesting(admin, FA1(fa1.addr), token_id, beneficiaries, 10000n, True, (None : timestamp option)) in
    let () = Test.set_source admin in
    let () = FA1_helper.approve_success((vesting.addr, 30n), fa1.contr) in
    let () = FA1_helper.assert_user_balance(fa1.taddr, admin, 1000n) in
    
    let () = Test.set_source admin in
    let () = Vesting_helper.assert_vesting_started(vesting.taddr, false) in
    let () = Vesting_helper.start_success(unit, 0tez, vesting.contr) in

    let () = FA1_helper.assert_user_balance(fa1.taddr, admin, 970n) in
    Vesting_helper.assert_vesting_started(vesting.taddr, true)
    
let test_failure_start_already_started =
    let accounts = Bootstrap.boot_accounts(Vesting_helper.zero_timestamp) in
    let (admin, alice, bob) = accounts in
    let token_id = 0n in
    let fa1 = Bootstrap.boot_fa1(token_id, admin, 1000n) in
    let beneficiaries = Map.literal[(alice, 20n);(bob, 10n)] in
    let vesting = Bootstrap.boot_vesting(admin, FA1(fa1.addr), token_id, beneficiaries, 10000n, True, (None : timestamp option)) in
    let () = Test.set_source admin in
    let () = FA1_helper.approve_success((vesting.addr, 30n), fa1.contr) in

    let () = Test.set_source admin in
    let () = Vesting_helper.start_success(unit, 0tez, vesting.contr) in
    let result = Vesting_helper.start(unit, 0tez, vesting.contr) in
    Assert.string_failure result Vesting.Errors.vesting_already_started

let test_failure_start_by_unauthorized_user =
    let accounts = Bootstrap.boot_accounts(Vesting_helper.zero_timestamp) in
    let (admin, alice, bob) = accounts in
    let token_id = 0n in
    let fa1 = Bootstrap.boot_fa1(token_id, admin, 1000n) in
    let beneficiaries = Map.literal[(alice, 20n);(bob, 10n)] in
    let vesting = Bootstrap.boot_vesting(admin, FA1(fa1.addr), token_id, beneficiaries, 10000n, True, (None : timestamp option)) in
    let () = Test.set_source admin in
    let () = FA1_helper.approve_success((vesting.addr, 30n), fa1.contr) in

    let () = Test.set_source alice in
    let result = Vesting_helper.start(unit, 0tez, vesting.contr) in
    Assert.string_failure result Vesting.Errors.not_admin

let test_failure_start_with_zero_duration =
    let accounts = Bootstrap.boot_accounts(Vesting_helper.zero_timestamp) in
    let (admin, alice, bob) = accounts in
    let token_id = 0n in
    let fa1 = Bootstrap.boot_fa1(token_id, admin, 1000n) in
    let beneficiaries = Map.literal[(alice, 20n);(bob, 10n)] in
    let vesting_duration = 0n in
    let vesting = Bootstrap.boot_vesting(admin, FA1(fa1.addr), token_id, beneficiaries, vesting_duration, True, (None : timestamp option)) in
    let () = Test.set_source admin in
    let () = FA1_helper.approve_success((vesting.addr, 30n), fa1.contr) in

    let () = Test.set_source admin in
    let result = Vesting_helper.start(unit, 0tez, vesting.contr) in
    Assert.string_failure result Vesting.Errors.vesting_duration_zero

let test_failure_start_with_duration_smaller_than_cliff =
    let accounts = Bootstrap.boot_accounts(Vesting_helper.zero_timestamp) in
    let (admin, alice, bob) = accounts in
    let token_id = 0n in
    let fa1 = Bootstrap.boot_fa1(token_id, admin, 1000n) in
    let beneficiaries = Map.literal[(alice, 20n);(bob, 10n)] in
    let vesting_duration = 100n in
    let vesting = Bootstrap.boot_vesting(admin, FA1(fa1.addr), token_id, beneficiaries, vesting_duration, True, (None : timestamp option)) in
    let () = Test.set_source admin in
    let () = FA1_helper.approve_success((vesting.addr, 30n), fa1.contr) in

    let () = Test.set_source admin in
    let result = Vesting_helper.start(unit, 0tez, vesting.contr) in
    Assert.string_failure result Vesting.Errors.vesting_duration_smaller_than_cliff_duration