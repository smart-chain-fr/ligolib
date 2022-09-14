#import "../helpers/vesting.mligo" "Vesting_helper"

(* Boostrapping of the test environment for Vesting *)
let boot_vesting () =
    let () = Test.reset_state 6n ([] : tez list) in

    let accounts =
        Test.nth_bootstrap_account 1,
        Test.nth_bootstrap_account 2
    in

    let vesting = Vesting_helper.originate(Vesting_helper.base_storage(accounts.0)) in
    (accounts, vesting)
