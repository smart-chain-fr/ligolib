#import "./helpers/assert.mligo" "Assert"
#import "./bootstrap/bootstrap.mligo" "Bootstrap"
#import "./helpers/log.mligo" "Log"
#import "./helpers/vesting.mligo" "Vesting_helper"
#import "./helpers/fa1.mligo" "FA1_helper"
#import "../../src/main.mligo" "Vesting"

let () = Log.describe("[Vesting - Revoke - FA1] test suite")

let metadata_empty : (string, bytes) big_map = (Big_map.empty : (string, bytes) big_map)

let test_failure_revoke_by_admin_before_start =
    let accounts = Bootstrap.boot_accounts(Vesting_helper.zero_timestamp) in
    let (admin, alice, bob) = accounts in
    let token_id = 0n in
    let fa1 = Bootstrap.boot_fa1(token_id, admin, 1000n) in
    let beneficiaries = Map.literal[(alice, 20n);(bob, 10n)] in
    let vesting = Bootstrap.boot_vesting(admin, FA1(fa1.addr), token_id, beneficiaries, 10000n, True, (None : timestamp option)) in
    let () = Test.set_source admin in
    let () = FA1_helper.approve_success((vesting.addr, 30n), fa1.contr) in

    let () = Test.set_source admin in
    let result = Vesting_helper.revoke(unit, 0tez, vesting.contr) in
    Assert.string_failure result Vesting.Errors.vesting_not_started

let test_failure_revoke_not_revocable =
    let accounts = Bootstrap.boot_accounts(Vesting_helper.zero_timestamp) in
    let (admin, alice, bob) = accounts in
    let token_id = 0n in
    let fa1 = Bootstrap.boot_fa1(token_id, admin, 1000n) in
    let beneficiaries = Map.literal[(alice, 20n);(bob, 10n)] in
    let revocable = False in 
    let vesting = Bootstrap.boot_vesting(admin, FA1(fa1.addr), token_id, beneficiaries, 10000n, revocable, (None : timestamp option)) in
    let () = Test.set_source admin in
    let () = FA1_helper.approve_success((vesting.addr, 30n), fa1.contr) in

    let () = Test.set_source admin in
    let () = Vesting_helper.start_success(unit, 0tez, vesting.contr) in
    let result = Vesting_helper.revoke(unit, 0tez, vesting.contr) in
    Assert.string_failure result Vesting.Errors.vesting_not_revocable

let test_failure_revoke_by_unauthorized =
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
    let () = Test.set_source alice in
    let result = Vesting_helper.revoke(unit, 0tez, vesting.contr) in
    Assert.string_failure result Vesting.Errors.not_admin

let test_failure_revoke_twice =
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
    let () = Vesting_helper.assert_vesting_revoked(vesting.taddr, false) in
    let () = Vesting_helper.revoke_success(unit, 0tez, vesting.contr) in
    let () = Vesting_helper.assert_vesting_revoked(vesting.taddr, true) in
    let result = Vesting_helper.revoke(unit, 0tez, vesting.contr) in
    Assert.string_failure result Vesting.Errors.vesting_already_revoked


let test_success_revoke_by_admin_after_start =
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
    let () = Vesting_helper.start_success(unit, 0tez, vesting.contr) in
    let () = FA1_helper.assert_user_balance(fa1.taddr, admin, 970n) in
    let () = Vesting_helper.assert_vesting_revoked(vesting.taddr, false) in
    let () = Vesting_helper.revoke_success(unit, 0tez, vesting.contr) in
    let () = FA1_helper.assert_user_balance(fa1.taddr, admin, 1000n) in
    Vesting_helper.assert_vesting_revoked(vesting.taddr, true)