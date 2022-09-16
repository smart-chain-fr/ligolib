#import "./helpers/assert.mligo" "Assert"
#import "./bootstrap/bootstrap.mligo" "Bootstrap"
#import "./helpers/log.mligo" "Log"
#import "./helpers/vesting.mligo" "Vesting_helper"
#import "./helpers/fa2.mligo" "FA2_helper"
#import "../../src/main.mligo" "Vesting"

let () = Log.describe("[Vesting - Revoke - FA2] test suite")

let metadata_empty : (string, bytes) big_map = (Big_map.empty : (string, bytes) big_map)

let test_failure_revoke_by_admin_before_start =
    let accounts = Bootstrap.boot_accounts(Vesting_helper.zero_timestamp) in
    let (admin, alice, bob) = accounts in
    let token_id = 0n in
    let fa2 = Bootstrap.boot_fa2(token_id, admin) in
    let beneficiaries = Map.literal[(alice, 20n);(bob, 10n)] in
    let vesting = Bootstrap.boot_vesting(admin, FA2(fa2.addr), token_id, beneficiaries, 10000n, True, (None : timestamp option)) in
    let () = FA2_helper.update_operators_success([Add_operator({owner=admin; operator=vesting.addr; token_id=token_id})], fa2.contr) in
    
    let () = Test.set_source admin in
    let result = Vesting_helper.revoke(unit, 0tez, vesting.contr) in
    Assert.string_failure result Vesting.Errors.vesting_not_started

let test_failure_revoke_not_revocable =
    let accounts = Bootstrap.boot_accounts(Vesting_helper.zero_timestamp) in
    let (admin, alice, bob) = accounts in
    let token_id = 0n in
    let fa2 = Bootstrap.boot_fa2(token_id, admin) in
    let beneficiaries = Map.literal[(alice, 20n);(bob, 10n)] in
    let revocable = False in 
    let vesting = Bootstrap.boot_vesting(admin, FA2(fa2.addr), token_id, beneficiaries, 10000n, revocable, (None : timestamp option)) in
    let () = FA2_helper.update_operators_success([Add_operator({owner=admin; operator=vesting.addr; token_id=token_id})], fa2.contr) in
    
    let () = Test.set_source admin in
    let () = Vesting_helper.start_success(unit, 0tez, vesting.contr) in
    let result = Vesting_helper.revoke(unit, 0tez, vesting.contr) in
    Assert.string_failure result Vesting.Errors.vesting_not_revocable

let test_failure_revoke_by_unauthorized =
    let accounts = Bootstrap.boot_accounts(Vesting_helper.zero_timestamp) in
    let (admin, alice, bob) = accounts in
    let token_id = 0n in
    let fa2 = Bootstrap.boot_fa2(token_id, admin) in
    let beneficiaries = Map.literal[(alice, 20n);(bob, 10n)] in
    let vesting = Bootstrap.boot_vesting(admin, FA2(fa2.addr), token_id, beneficiaries, 10000n, True, (None : timestamp option)) in
    let () = FA2_helper.update_operators_success([Add_operator({owner=admin; operator=vesting.addr; token_id=token_id})], fa2.contr) in
    
    let () = Test.set_source admin in
    let () = Vesting_helper.start_success(unit, 0tez, vesting.contr) in
    let () = Test.set_source alice in
    let result = Vesting_helper.revoke(unit, 0tez, vesting.contr) in
    Assert.string_failure result Vesting.Errors.not_admin

let test_failure_revoke_twice =
    let accounts = Bootstrap.boot_accounts(Vesting_helper.zero_timestamp) in
    let (admin, alice, bob) = accounts in
    let token_id = 0n in
    let fa2 = Bootstrap.boot_fa2(token_id, admin) in
    let beneficiaries = Map.literal[(alice, 20n);(bob, 10n)] in
    let vesting = Bootstrap.boot_vesting(admin, FA2(fa2.addr), token_id, beneficiaries, 10000n, True, (None : timestamp option)) in
    let () = FA2_helper.update_operators_success([Add_operator({owner=admin; operator=vesting.addr; token_id=token_id})], fa2.contr) in
    
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
    let fa2 = Bootstrap.boot_fa2(token_id, admin) in
    let beneficiaries = Map.literal[(alice, 20n);(bob, 10n)] in
    let vesting = Bootstrap.boot_vesting(admin, FA2(fa2.addr), token_id, beneficiaries, 10000n, True, (None : timestamp option)) in
    let () = FA2_helper.update_operators_success([Add_operator({owner=admin; operator=vesting.addr; token_id=token_id})], fa2.contr) in
    
    let () = Test.set_source admin in
    let () = Vesting_helper.start_success(unit, 0tez, vesting.contr) in
    let () = Vesting_helper.assert_vesting_revoked(vesting.taddr, false) in
    let () = Vesting_helper.revoke_success(unit, 0tez, vesting.contr) in
    Vesting_helper.assert_vesting_revoked(vesting.taddr, true)