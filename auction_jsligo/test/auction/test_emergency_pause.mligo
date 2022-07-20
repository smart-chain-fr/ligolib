
#import "../contracts/factory/main.mligo" "Factory"
#import "../../contracts/auction/main.mligo" "Auction"
#import "bootstrap.mligo" "Bootstrap"
#import "../helpers/common.mligo" "Common_helper"

type fa2_storage = Factory.NFT_FA2.Storage.t
type ext = Factory.NFT_FA2.extension
type ext_fa2_storage = ext fa2_storage

let test_emergency_pause_should_work =
    // ARRANGE
    let (alice, bob, reserve, royalties, admin, frank, baker, accountZero, accountOne) = Bootstrap.bootstrap_accounts(("2022-01-01T00:22:10Z" : timestamp)) in
    let () = Test.set_baker_policy (By_account baker) in
    let factory_originated = Bootstrap.bootstrap_factory_NFT() in 
    let fa2_nft_originated = Bootstrap.bootstrap_NFT_with_one_token(factory_originated, alice, "alice_collection_1", "QRcode", 0x623d82eff132) in
    let partial_auction_storage : Auction.Storage.t = 
    {
        admin = admin ; 
        commissionFee = 2500n ; 
        extension_duration = 100n ; 
        isPaused = false ; 
        min_bp_bid = 10n ; 
        nftSaleId = 0n ; 
        reserveAddress = reserve ; 
        royaltiesStorage = royalties;
        auctionIdToAuction = (Big_map.empty : Auction.Storage.auctions)
    } in
    let auction_originated = Bootstrap.bootstrap_auction_with_storage(partial_auction_storage, 23mutez) in

    // let (accounts, _factory_originated, auction_originated, fa2_nft_originated, _fa1_originated, _fa2_originated, _nft_multi_originated, _bob_fa2_nft_originated) = Bootstrap.bootstrap_full((None : Auction.Storage.t option)) in
    // let (alice, bob, _reserve, _royalties, admin, frank, baker, accountZero, accountOne) = accounts in
    // let () = Test.set_baker_policy (By_account baker) in

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
    let (alice, bob, reserve, royalties, admin, frank, baker, accountZero, accountOne) = Bootstrap.bootstrap_accounts(("2022-01-01T00:22:10Z" : timestamp)) in
    let () = Test.set_baker_policy (By_account baker) in
    let factory_originated = Bootstrap.bootstrap_factory_NFT() in 
    let fa2_nft_originated = Bootstrap.bootstrap_NFT_with_one_token(factory_originated, alice, "alice_collection_1", "QRcode", 0x623d82eff132) in
    let partial_auction_storage : Auction.Storage.t = 
    {
        admin = admin ; 
        commissionFee = 2500n ; 
        extension_duration = 100n ; 
        isPaused = false ; 
        min_bp_bid = 10n ; 
        nftSaleId = 0n ; 
        reserveAddress = reserve ; 
        royaltiesStorage = royalties;
        auctionIdToAuction = (Big_map.empty : Auction.Storage.auctions)
    } in
    let auction_originated = Bootstrap.bootstrap_auction_with_storage(partial_auction_storage, 23mutez) in

    // let (accounts, _factory_originated, auction_originated, fa2_nft_originated, _fa1_originated, _fa2_originated, _nft_multi_originated, _bob_fa2_nft_originated) = Bootstrap.bootstrap_full((None : Auction.Storage.t option)) in
    // let (alice, bob, _reserve, _royalties, admin, frank, baker, accountZero, accountOne) = accounts in
    // let () = Test.set_baker_policy (By_account baker) in

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

