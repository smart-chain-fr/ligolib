#import "../helpers/ticketing.mligo" "Ticketing_helper"
#import "../helpers/nft.mligo" "NFT_helper"

(* Boostrapping of the test environment for Factory *)
let boot_ticketing () =
    let () = Test.reset_state 6n ([] : tez list) in

    let accounts =
        Test.nth_bootstrap_account 1,
        Test.nth_bootstrap_account 2
    in

    let ticketing = Ticketing_helper.originate(Ticketing_helper.base_storage) in
    (accounts, ticketing)

(* Boostrapping of the test environment for NFT *)
let boot_nft () =
    let () = Test.reset_state 6n ([] : tez list) in

    let (admin, creator) =
        Test.nth_bootstrap_account 1,
        Test.nth_bootstrap_account 2
    in
    let accounts = admin, creator,
        Test.nth_bootstrap_account 3,
        Test.nth_bootstrap_account 4,
        Test.nth_bootstrap_account 5
    in

    //let nft = NFT_helper.originate(NFT_helper.base_storage(admin, creator)) in
    let nft = NFT_helper.originate_from_file(NFT_helper.base_storage(admin, creator, accounts.4)) in
    (accounts, nft)
