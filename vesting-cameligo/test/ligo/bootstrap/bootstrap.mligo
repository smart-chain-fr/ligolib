#import "../helpers/vesting.mligo" "Vesting_helper"
#import "../helpers/fa2.mligo" "FA2_helper"

(* Boostrapping of the test environment for Vesting *)
let boot_accounts () =
    let () = Test.reset_state 6n ([] : tez list) in

    let accounts =
        Test.nth_bootstrap_account 1,
        Test.nth_bootstrap_account 2,
        Test.nth_bootstrap_account 3
    in
    accounts

let boot_fa2 (token_id, user : nat * address) = 
    let fa2 = FA2_helper.originate(FA2_helper.base_storage(token_id, user)) in
    fa2

let boot_vesting (admin, token_address, token_id, beneficiaries, vesting_duration : address * address * nat * (address, nat)map * nat) =
    let vesting = Vesting_helper.originate(Vesting_helper.base_storage(admin, token_address, token_id, beneficiaries, vesting_duration)) in
    vesting