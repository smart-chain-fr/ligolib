#import "../helpers/ticketer.mligo" "Ticketer_helper"

(* Boostrapping of the test environment *)
let boot (initial_price: tez) =
    let () = Test.reset_state 6n ([] : tez list) in

    let accounts =
        Test.nth_bootstrap_account 1,
        Test.nth_bootstrap_account 2
    in

    let contr = Ticketer_helper.originate(Ticketer_helper.base_storage initial_price) in
    (accounts, contr)
