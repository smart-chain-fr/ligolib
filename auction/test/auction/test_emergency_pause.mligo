
#import "../../contracts/factory/main.mligo" "Factory"
#import "../../contracts/auction/main.mligo" "Auction"
#import "bootstrap.mligo" "Bootstrap"
#import "../helpers/common.mligo" "Common_helper"

type fa2_storage = Factory.NFT_FA2.Storage.t
type ext = Factory.NFT_FA2.extension
type ext_fa2_storage = ext fa2_storage

let test_emergency_pause_should_work =
    // ARRANGE
    let (accounts, _factory_originated, auction_originated, fa2_nft_originated, _fa1_originated, _fa2_originated, _nft_multi_originated, _bob_fa2_nft_originated) = Bootstrap.bootstrap_full((None : Auction.Storage.t option)) in
    let (alice, bob, _reserve, _royalties, admin, frank, baker, accountZero, accountOne) = accounts in
    let () = Test.set_baker_policy (By_account baker) in

    // set contract in pause
    let _admin_set_auction_contract_in_pause =
        let () = Test.log("_admin_set_auction_contract_in_pause") in

        let () = Test.set_source admin in
        let auction_contract : Auction.parameter contract = Test.to_contract auction_originated.taddr in
        let pause_param : Auction.Parameter.pause_param = true in
        let _ = Test.transfer_to_contract_exn auction_contract (EmergencyPause(pause_param) : Auction.parameter) 0mutez in

        // verify auction contract is in pause
        let auction_storage_after : Auction.storage = Test.get_storage auction_originated.taddr in
        let _check_counter : unit = assert_with_error (auction_storage_after.isPaused=true) "Auction contract should be in pause" in
        "OK"
    in
    ()

let test_emergency_pause_should_fail =
    // ARRANGE
    let (accounts, _factory_originated, auction_originated, fa2_nft_originated, _fa1_originated, _fa2_originated, _nft_multi_originated, _bob_fa2_nft_originated) = Bootstrap.bootstrap_full((None : Auction.Storage.t option)) in
    let (alice, bob, _reserve, _royalties, admin, frank, baker, accountZero, accountOne) = accounts in
    let () = Test.set_baker_policy (By_account baker) in

    // Alice attempt to set contract in pause
    let _alice_set_auction_contract_in_pause =
        let () = Test.log("_alice_set_auction_contract_in_pause") in

        let () = Test.set_source alice in
        let auction_contract : Auction.parameter contract = Test.to_contract auction_originated.taddr in
        let pause_param : Auction.Parameter.pause_param = true in
        let fail_err = Test.transfer_to_contract auction_contract (EmergencyPause(pause_param) : Auction.parameter) 0mutez in
        let () = Common_helper.assert_string_failure fail_err Auction.Errors.not_admin in

        // verify auction contract is in pause
        let auction_storage_after : Auction.storage = Test.get_storage auction_originated.taddr in
        let _check_counter : unit = assert_with_error (auction_storage_after.isPaused=false) "Auction contract should NOT be in pause" in
        "OK"
    in
    ()

