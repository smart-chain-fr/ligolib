#import "./helpers/assert.mligo" "Assert"
#import "./bootstrap/bootstrap.mligo" "Bootstrap"
#import "./helpers/log.mligo" "Log"
#import "./helpers/vesting.mligo" "Vesting_helper"
#import "./helpers/fa2.mligo" "FA2_helper"
#import "../../src/main.mligo" "Vesting"

let () = Log.describe("[Vesting - Release - FA2] test suite")

let metadata_empty : (string, bytes) big_map = (Big_map.empty : (string, bytes) big_map)



let test_failure_release_during_cliff =
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
    let result = Vesting_helper.release(unit, 0tez, vesting.contr) in
    Assert.string_failure result Vesting.Errors.nothing_to_release

let test_failure_release_not_started =
    let accounts = Bootstrap.boot_accounts(Vesting_helper.zero_timestamp) in
    let (admin, alice, bob) = accounts in
    let token_id = 0n in
    let fa2 = Bootstrap.boot_fa2(token_id, admin) in
    let beneficiaries = Map.literal[(alice, 20n);(bob, 10n)] in
    let vesting = Bootstrap.boot_vesting(admin, FA2(fa2.addr), token_id, beneficiaries, 10000n, True, (None : timestamp option)) in
    let () = FA2_helper.update_operators_success([Add_operator({owner=admin; operator=vesting.addr; token_id=token_id})], fa2.contr) in

    let () = Test.set_source alice in
    let result = Vesting_helper.release(unit, 0tez, vesting.contr) in
    Assert.string_failure result Vesting.Errors.vesting_not_started


let test_success_release_at_end_of_duration =
    let accounts = Bootstrap.boot_accounts(Vesting_helper.day3_timestamp) in
    let (admin, alice, bob) = accounts in
    let token_id = 0n in
    let fa2 = Bootstrap.boot_fa2(token_id, admin) in
    let beneficiaries = Map.literal[(alice, 20n);(bob, 10n)] in
    let vesting = Bootstrap.boot_vesting(admin, FA2(fa2.addr), token_id, beneficiaries, 10000n, True, Some(Vesting_helper.day2_timestamp)) in
    let () = FA2_helper.update_operators_success([Add_operator({owner=admin; operator=vesting.addr; token_id=token_id})], fa2.contr) in
    let () = FA2_helper.transfer_success([{from_=admin; tx=[{to_=vesting.addr; token_id=token_id; amount=30n}]}], fa2.contr) in
    let () = FA2_helper.assert_user_balance(fa2.taddr, alice, 0n, 0n) in

    let () = Test.set_source alice in
    let () = Vesting_helper.release_success(unit, 0tez, vesting.contr) in
    let () = FA2_helper.assert_user_balance(fa2.taddr, alice, 0n, 20n) in
    Vesting_helper.assert_released_amount(vesting.taddr, alice, 20n)


