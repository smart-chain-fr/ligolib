#import "./helpers/assert.mligo" "Assert"
#import "./bootstrap/bootstrap.mligo" "Bootstrap"
#import "./helpers/log.mligo" "Log"
#import "./helpers/vesting.mligo" "Vesting_helper"
#import "./helpers/fa2.mligo" "FA2_helper"
#import "../../src/main.mligo" "Vesting"

let () = Log.describe("[Vesting - Start] test suite")

let metadata_empty : (string, bytes) big_map = (Big_map.empty : (string, bytes) big_map)

let test_success_start_by_admin =
    let accounts = Bootstrap.boot_accounts() in
    let (admin, alice, bob) = accounts in
    let token_id = 0n in
    let fa2 = Bootstrap.boot_fa2(token_id, admin) in
    let beneficiaries = Map.literal[(alice, 20n);(bob, 10n)] in
    let vesting = Bootstrap.boot_vesting(admin, fa2.addr, token_id, beneficiaries, 10000n) in
    let () = FA2_helper.update_operators_success([Add_operator({owner=admin; operator=vesting.addr; token_id=token_id})], fa2.contr) in
    
    let () = Test.set_source admin in
    let () = Vesting_helper.assert_vesting_started(vesting.taddr, false) in
    let () = Vesting_helper.start_success(unit, 0tez, vesting.contr) in
    Vesting_helper.assert_vesting_started(vesting.taddr, true)
    
let test_failure_start_already_started =
    let accounts = Bootstrap.boot_accounts() in
    let (admin, alice, bob) = accounts in
    let token_id = 0n in
    let fa2 = Bootstrap.boot_fa2(token_id, admin) in
    let beneficiaries = Map.literal[(alice, 20n);(bob, 10n)] in
    let vesting = Bootstrap.boot_vesting(admin, fa2.addr, token_id, beneficiaries, 10000n) in
    let () = FA2_helper.update_operators_success([Add_operator({owner=admin; operator=vesting.addr; token_id=token_id})], fa2.contr) in

    let () = Test.set_source admin in
    let () = Vesting_helper.start_success(unit, 0tez, vesting.contr) in
    let result = Vesting_helper.start(unit, 0tez, vesting.contr) in
    Assert.string_failure result Vesting.Errors.vesting_already_started

let test_failure_start_by_unauthorized_user =
    let accounts = Bootstrap.boot_accounts() in
    let (admin, alice, bob) = accounts in
    let token_id = 0n in
    let fa2 = Bootstrap.boot_fa2(token_id, admin) in
    let beneficiaries = Map.literal[(alice, 20n);(bob, 10n)] in
    let vesting = Bootstrap.boot_vesting(admin, fa2.addr, token_id, beneficiaries, 10000n) in
    let () = FA2_helper.update_operators_success([Add_operator({owner=admin; operator=vesting.addr; token_id=token_id})], fa2.contr) in

    let () = Test.set_source alice in
    let result = Vesting_helper.start(unit, 0tez, vesting.contr) in
    Assert.string_failure result Vesting.Errors.not_admin

let test_failure_start_with_zero_duration =
    let accounts = Bootstrap.boot_accounts() in
    let (admin, alice, bob) = accounts in
    let token_id = 0n in
    let fa2 = Bootstrap.boot_fa2(token_id, admin) in
    let beneficiaries = Map.literal[(alice, 20n);(bob, 10n)] in
    let vesting_duration = 0n in
    let vesting = Bootstrap.boot_vesting(admin, fa2.addr, token_id, beneficiaries, vesting_duration) in
    let () = FA2_helper.update_operators_success([Add_operator({owner=admin; operator=vesting.addr; token_id=token_id})], fa2.contr) in

    let () = Test.set_source admin in
    let result = Vesting_helper.start(unit, 0tez, vesting.contr) in
    Assert.string_failure result Vesting.Errors.vesting_duration_zero

let test_failure_start_with_duration_smaller_than_cliff =
    let accounts = Bootstrap.boot_accounts() in
    let (admin, alice, bob) = accounts in
    let token_id = 0n in
    let fa2 = Bootstrap.boot_fa2(token_id, admin) in
    let beneficiaries = Map.literal[(alice, 20n);(bob, 10n)] in
    let vesting_duration = 100n in
    let vesting = Bootstrap.boot_vesting(admin, fa2.addr, token_id, beneficiaries, vesting_duration) in
    let () = FA2_helper.update_operators_success([Add_operator({owner=admin; operator=vesting.addr; token_id=token_id})], fa2.contr) in

    let () = Test.set_source admin in
    let result = Vesting_helper.start(unit, 0tez, vesting.contr) in
    Assert.string_failure result Vesting.Errors.vesting_duration_smaller_than_cliff_duration