#import "../helpers/vesting.mligo" "Vesting_helper"
#import "../helpers/fa1.mligo" "FA1_helper"
#import "../helpers/fa2.mligo" "FA2_helper"

(* Boostrapping of the test environment for Vesting *)
let boot_accounts (inittime : timestamp) =
    let () = Test.reset_state_at inittime 6n ([] : tez list) in

    let accounts =
        Test.nth_bootstrap_account 1,
        Test.nth_bootstrap_account 2,
        Test.nth_bootstrap_account 3
    in
    accounts

let boot_fa1 (token_id, user : nat * address) = 
    let fa1 = FA1_helper.originate(FA1_helper.base_storage(token_id, user)) in
    fa1


let boot_fa2 (token_id, user : nat * address) = 
    let fa2 = FA2_helper.originate(FA2_helper.base_storage(token_id, user)) in
    fa2

let boot_vesting (admin, token_address, token_id, beneficiaries, vesting_duration, revocable, start_at : address * Vesting_helper.Vesting.Storage.fa_type * nat * (address, nat)map * nat * bool * timestamp option) =
    let vesting = Vesting_helper.originate(Vesting_helper.base_storage(admin, token_address, token_id, beneficiaries, vesting_duration, revocable, start_at)) in
    vesting