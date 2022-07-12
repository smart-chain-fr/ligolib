
#import "../../contracts/factory/main.mligo" "Factory"
#import "../../contracts/auction/main.mligo" "Auction"
#import "bootstrap.mligo" "Bootstrap"
#import "../helpers/common.mligo" "Common_helper"

type fa2_storage = Factory.NFT_FA2.Storage.t
type ext = Factory.NFT_FA2.extension
type ext_fa2_storage = ext fa2_storage

let test_set_nft_should_work =
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

    let _alice_create_auction_should_work = 
        let () = Test.log("_alice_create_auction_should_work") in
        // retrieve FA2 address collection
        let fa2_nft_address : address = fa2_nft_originated.addr in
        let auction_storage : Auction.Storage.t = Test.get_storage auction_originated.taddr in
        let reserveBalBefore : tez = Test.get_balance auction_storage.reserveAddress in
        // let fa2_storage_before : ext_fa2_storage = Test.get_storage fa2_nft_originated.taddr in
        // let () = Test.log(fa2_storage_before) in

        // APPROVE marketplace to transfer token 1
        let () = Test.set_source alice in
        let fa2_contract : Factory.NFT_FA2.parameter contract = Test.to_contract fa2_nft_originated.taddr in
        let update_op : Factory.NFT_FA2.NFT.update_operators = [(Add_operator({owner=alice; operator=auction_originated.addr; token_id=1n}) : Factory.NFT_FA2.NFT.unit_update)] in
        let _ = Test.transfer_to_contract_exn fa2_contract (Update_operators(update_op) : Factory.NFT_FA2.parameter) 0mutez in

        // Set NFT 
        let param_set_nft : Auction.Parameter.set_nft_auction_param = {
            nftAddress=fa2_nft_address;
            tokenId=1n;
            reservePrice=12n;
            auctionBiddingPeriod=100n;
            auctionExpirationPeriod=1000n;
            assetClass=NFT;
            tokenAmount=1n;
        } in
        let () = Test.set_source alice in
        let _ = Test.transfer_to_contract_exn auction_originated.contr (SetNftAuction(param_set_nft) : Auction.parameter) 0mutez in
        
        // verify auction has been recorded in the storage
        let auction_storage_after : Auction.storage = Test.get_storage auction_originated.taddr in
        let _check_counter : unit = assert_with_error (auction_storage_after.nftSaleId=1n) "nftSaleId does not match expected value" in
        let found_auction_opt : Auction.Storage.nftauction option = Big_map.find_opt 0n auction_storage_after.auctionIdToAuction in
        let found_auction : Auction.Storage.nftauction = match found_auction_opt with
        | None -> failwith("auction 0 does not exist")
        | Some auct -> auct
        in
        let _check_field : unit = assert_with_error (found_auction.nftAddress=fa2_nft_address) "does not match expected value" in
        let _check_field : unit = assert_with_error (found_auction.tokenId=1n) "does not match expected value" in
        let _check_field : unit = assert_with_error (found_auction.reservePrice=12n) "does not match expected value" in
        let _check_field : unit = assert_with_error (found_auction.biddingPeriod=100n) "does not match expected value" in
        //let _check_field : unit = assert_with_error (found_auction.expirationTime=Some(Tezos.get_now() + int(param_set_nft.auctionExpirationPeriod))) "does not match expected value" in
        let _check_field : unit = assert_with_error (found_auction.assetClass=NFT) "does not match expected value" in

        // verify alice NFT token sent to auction contract
        let fa2_storage : ext_fa2_storage = Test.get_storage fa2_nft_originated.taddr in
        let auction_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage auction_originated.addr 1n in
        let _check_auction_ownership_of_token_1 : unit = assert(auction_balance_token_1 = 1n) in
        let alice_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage alice 1n in
        let _check_alice_ownership_of_token_1 : unit = assert(alice_balance_token_1 = 0n) in
        "OK"
    in
    ()

let test_set_nft_in_pause_should_fail =
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
        let () = Test.log("_set_auction_contract_in_pause") in

        let () = Test.set_source admin in
        let auction_contract : Auction.parameter contract = Test.to_contract auction_originated.taddr in
        let pause_param : Auction.Parameter.pause_param = true in
        let _ = Test.transfer_to_contract_exn auction_contract (EmergencyPause(pause_param) : Auction.parameter) 0mutez in
        "OK"
    in

    let _alice_create_auction_when_in_pause_should_fail = 
        let () = Test.log("_alice_create_auction_when_in_pause_should_fail") in
        // retrieve FA2 address collection
        let fa2_nft_address : address = fa2_nft_originated.addr in
        let auction_storage : Auction.Storage.t = Test.get_storage auction_originated.taddr in
        let reserveBalBefore : tez = Test.get_balance auction_storage.reserveAddress in
        // let fa2_storage_before : ext_fa2_storage = Test.get_storage fa2_nft_originated.taddr in
        // let () = Test.log(fa2_storage_before) in

        // APPROVE marketplace to transfer token 1
        let () = Test.set_source alice in
        let fa2_contract : Factory.NFT_FA2.parameter contract = Test.to_contract fa2_nft_originated.taddr in
        let update_op : Factory.NFT_FA2.NFT.update_operators = [(Add_operator({owner=alice; operator=auction_originated.addr; token_id=1n}) : Factory.NFT_FA2.NFT.unit_update)] in
        let _ = Test.transfer_to_contract_exn fa2_contract (Update_operators(update_op) : Factory.NFT_FA2.parameter) 0mutez in

        // Set NFT 
        let param_set_nft : Auction.Parameter.set_nft_auction_param = {
            nftAddress=fa2_nft_address;
            tokenId=1n;
            reservePrice=12n;
            auctionBiddingPeriod=100n;
            auctionExpirationPeriod=1000n;
            assetClass=NFT;
            tokenAmount=1n;
        } in
        let () = Test.set_source alice in
        let fail_err = Test.transfer_to_contract auction_originated.contr (SetNftAuction(param_set_nft) : Auction.parameter) 0mutez in
        let () = Common_helper.assert_string_failure fail_err Auction.Errors.in_pause in

        // verify auction has NOT been recorded in the storage
        let auction_storage_after : Auction.storage = Test.get_storage auction_originated.taddr in
        let _check_counter : unit = assert_with_error (auction_storage_after.nftSaleId=0n) "nftSaleId does not match expected value" in
        let found_auction_opt : Auction.Storage.nftauction option = Big_map.find_opt 0n auction_storage_after.auctionIdToAuction in
        let found_auction : bool = match found_auction_opt with
        | None -> false
        | Some auct -> true
        in
        let _check_auction_not_created : unit = assert_with_error (found_auction = false) "auction should not be created" in

        // verify alice NFT token is NOT sent to auction contract
        let fa2_storage : ext_fa2_storage = Test.get_storage fa2_nft_originated.taddr in
        let auction_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage auction_originated.addr 1n in
        let _check_auction_ownership_of_token_1 : unit = assert(auction_balance_token_1 = 0n) in
        let alice_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage alice 1n in
        let _check_alice_ownership_of_token_1 : unit = assert(alice_balance_token_1 = 1n) in
        "OK"
    in
    ()


let test_set_nft_wrong_nft_contract_should_fail =
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

    let _alice_create_auction_with_wrong_nft_contract_should_fail = 
        let () = Test.log("_alice_create_auction_with_wrong_nft_contract_should_fail") in
        // retrieve FA2 address collection
        let fa2_nft_address : address = fa2_nft_originated.addr in
        let auction_originated_address : address = auction_originated.addr in
        let auction_storage : Auction.Storage.t = Test.get_storage auction_originated.taddr in

        // APPROVE marketplace to transfer token 1
        let () = Test.set_source alice in
        let fa2_contract : Factory.NFT_FA2.parameter contract = Test.to_contract fa2_nft_originated.taddr in
        let update_op : Factory.NFT_FA2.NFT.update_operators = [(Add_operator({owner=alice; operator=auction_originated.addr; token_id=1n}) : Factory.NFT_FA2.NFT.unit_update)] in
        let _ = Test.transfer_to_contract_exn fa2_contract (Update_operators(update_op) : Factory.NFT_FA2.parameter) 0mutez in

        // Set NFT 
        let param_set_nft : Auction.Parameter.set_nft_auction_param = {
            nftAddress=auction_originated_address;
            tokenId=1n;
            reservePrice=12n;
            auctionBiddingPeriod=100n;
            auctionExpirationPeriod=1000n;
            assetClass=NFT;
            tokenAmount=1n;
        } in
        let () = Test.set_source alice in
        let fail_err = Test.transfer_to_contract auction_originated.contr (SetNftAuction(param_set_nft) : Auction.parameter) 0mutez in
        let () = Common_helper.assert_string_failure fail_err Auction.Errors.nft_address_does_not_exist in

        // verify auction has NOT been recorded in the storage
        let auction_storage_after : Auction.storage = Test.get_storage auction_originated.taddr in
        let _check_counter : unit = assert_with_error (auction_storage_after.nftSaleId=0n) "nftSaleId does not match expected value" in
        let found_auction_opt : Auction.Storage.nftauction option = Big_map.find_opt 0n auction_storage_after.auctionIdToAuction in
        let found_auction : bool = match found_auction_opt with
        | None -> false
        | Some auct -> true
        in
        let _check_auction_not_created : unit = assert_with_error (found_auction = false) "auction should not be created" in

        // verify alice NFT token is NOT sent to auction contract
        let fa2_storage : ext_fa2_storage = Test.get_storage fa2_nft_originated.taddr in
        let auction_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage auction_originated.addr 1n in
        let _check_auction_ownership_of_token_1 : unit = assert(auction_balance_token_1 = 0n) in
        let alice_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage alice 1n in
        let _check_alice_ownership_of_token_1 : unit = assert(alice_balance_token_1 = 1n) in
        "OK"
    in
    ()

let test_set_nft_without_bidding_period_should_fail =
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

    let _alice_create_auction_without_bidding_period_should_fail = 
        let () = Test.log("_alice_create_auction_without_bidding_period_should_fail") in
        // retrieve FA2 address collection
        let fa2_nft_address : address = fa2_nft_originated.addr in
        let auction_storage : Auction.Storage.t = Test.get_storage auction_originated.taddr in

        // APPROVE marketplace to transfer token 1
        let () = Test.set_source alice in
        let fa2_contract : Factory.NFT_FA2.parameter contract = Test.to_contract fa2_nft_originated.taddr in
        let update_op : Factory.NFT_FA2.NFT.update_operators = [(Add_operator({owner=alice; operator=auction_originated.addr; token_id=1n}) : Factory.NFT_FA2.NFT.unit_update)] in
        let _ = Test.transfer_to_contract_exn fa2_contract (Update_operators(update_op) : Factory.NFT_FA2.parameter) 0mutez in

        // Set NFT 
        let param_set_nft : Auction.Parameter.set_nft_auction_param = {
            nftAddress=fa2_nft_address;
            tokenId=1n;
            reservePrice=12n;
            auctionBiddingPeriod=0n;
            auctionExpirationPeriod=1000n;
            assetClass=NFT;
            tokenAmount=1n;
        } in
        let () = Test.set_source alice in
        let fail_err = Test.transfer_to_contract auction_originated.contr (SetNftAuction(param_set_nft) : Auction.parameter) 0mutez in
        let () = Common_helper.assert_string_failure fail_err Auction.Errors.no_bidding_period in
        
        // verify auction has NOT been recorded in the storage
        let auction_storage_after : Auction.storage = Test.get_storage auction_originated.taddr in
        let _check_counter : unit = assert_with_error (auction_storage_after.nftSaleId=0n) "nftSaleId does not match expected value" in
        let found_auction_opt : Auction.Storage.nftauction option = Big_map.find_opt 0n auction_storage_after.auctionIdToAuction in
        let found_auction : bool = match found_auction_opt with
        | None -> false
        | Some auct -> true
        in
        let _check_auction_not_created : unit = assert_with_error (found_auction = false) "auction should not be created" in

        // verify alice NFT token is NOT sent to auction contract
        let fa2_storage : ext_fa2_storage = Test.get_storage fa2_nft_originated.taddr in
        let auction_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage auction_originated.addr 1n in
        let _check_auction_ownership_of_token_1 : unit = assert(auction_balance_token_1 = 0n) in
        let alice_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage alice 1n in
        let _check_alice_ownership_of_token_1 : unit = assert(alice_balance_token_1 = 1n) in
        "OK"
    in
    ()

let test_set_nft_without_expiration_period_should_fail =
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

    let _alice_create_auction_without_expiration_period_should_fail = 
        let () = Test.log("_alice_create_auction_without_expiration_period_should_fail") in
        // retrieve FA2 address collection
        let fa2_nft_address : address = fa2_nft_originated.addr in
        let auction_storage : Auction.Storage.t = Test.get_storage auction_originated.taddr in

        // APPROVE marketplace to transfer token 1
        let () = Test.set_source alice in
        let fa2_contract : Factory.NFT_FA2.parameter contract = Test.to_contract fa2_nft_originated.taddr in
        let update_op : Factory.NFT_FA2.NFT.update_operators = [(Add_operator({owner=alice; operator=auction_originated.addr; token_id=1n}) : Factory.NFT_FA2.NFT.unit_update)] in
        let _ = Test.transfer_to_contract_exn fa2_contract (Update_operators(update_op) : Factory.NFT_FA2.parameter) 0mutez in

        // Set NFT 
        let param_set_nft : Auction.Parameter.set_nft_auction_param = {
            nftAddress=fa2_nft_address;
            tokenId=1n;
            reservePrice=12n;
            auctionBiddingPeriod=100n;
            auctionExpirationPeriod=0n;
            assetClass=NFT;
            tokenAmount=1n;
        } in
        let () = Test.set_source alice in
        let fail_err = Test.transfer_to_contract auction_originated.contr (SetNftAuction(param_set_nft) : Auction.parameter) 0mutez in
        let () = Common_helper.assert_string_failure fail_err Auction.Errors.no_expiration_period in

        // verify auction has NOT been recorded in the storage
        let auction_storage_after : Auction.storage = Test.get_storage auction_originated.taddr in
        let _check_counter : unit = assert_with_error (auction_storage_after.nftSaleId=0n) "nftSaleId does not match expected value" in
        let found_auction_opt : Auction.Storage.nftauction option = Big_map.find_opt 0n auction_storage_after.auctionIdToAuction in
        let found_auction : bool = match found_auction_opt with
        | None -> false
        | Some auct -> true
        in
        let _check_auction_not_created : unit = assert_with_error (found_auction = false) "auction should not be created" in

        // verify alice NFT token is NOT sent to auction contract
        let fa2_storage : ext_fa2_storage = Test.get_storage fa2_nft_originated.taddr in
        let auction_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage auction_originated.addr 1n in
        let _check_auction_ownership_of_token_1 : unit = assert(auction_balance_token_1 = 0n) in
        let alice_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage alice 1n in
        let _check_alice_ownership_of_token_1 : unit = assert(alice_balance_token_1 = 1n) in
        "OK"
    in
    ()

let test_set_nft_without_reserve_price_should_fail =
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
    
    let _alice_create_auction_without_reserve_price_should_fail = 
        let () = Test.log("_alice_create_auction_without_expiration_period_should_fail") in
        // retrieve FA2 address collection
        let fa2_nft_address : address = fa2_nft_originated.addr in
        let auction_storage : Auction.Storage.t = Test.get_storage auction_originated.taddr in

        // APPROVE marketplace to transfer token 1
        let () = Test.set_source alice in
        let fa2_contract : Factory.NFT_FA2.parameter contract = Test.to_contract fa2_nft_originated.taddr in
        let update_op : Factory.NFT_FA2.NFT.update_operators = [(Add_operator({owner=alice; operator=auction_originated.addr; token_id=1n}) : Factory.NFT_FA2.NFT.unit_update)] in
        let _ = Test.transfer_to_contract_exn fa2_contract (Update_operators(update_op) : Factory.NFT_FA2.parameter) 0mutez in

        // Set NFT 
        let param_set_nft : Auction.Parameter.set_nft_auction_param = {
            nftAddress=fa2_nft_address;
            tokenId=1n;
            reservePrice=0n;
            auctionBiddingPeriod=100n;
            auctionExpirationPeriod=1000n;
            assetClass=NFT;
            tokenAmount=1n;
        } in
        let () = Test.set_source alice in
        let fail_err = Test.transfer_to_contract auction_originated.contr (SetNftAuction(param_set_nft) : Auction.parameter) 0mutez in
        let () = Common_helper.assert_string_failure fail_err Auction.Errors.no_reserve_price in

        // verify auction has NOT been recorded in the storage
        let auction_storage_after : Auction.storage = Test.get_storage auction_originated.taddr in
        let _check_counter : unit = assert_with_error (auction_storage_after.nftSaleId=0n) "nftSaleId does not match expected value" in
        let found_auction_opt : Auction.Storage.nftauction option = Big_map.find_opt 0n auction_storage_after.auctionIdToAuction in
        let found_auction : bool = match found_auction_opt with
        | None -> false
        | Some auct -> true
        in
        let _check_auction_not_created : unit = assert_with_error (found_auction = false) "auction should not be created" in

        // verify alice NFT token is NOT sent to auction contract
        let fa2_storage : ext_fa2_storage = Test.get_storage fa2_nft_originated.taddr in
        let auction_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage auction_originated.addr 1n in
        let _check_auction_ownership_of_token_1 : unit = assert(auction_balance_token_1 = 0n) in
        let alice_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage alice 1n in
        let _check_alice_ownership_of_token_1 : unit = assert(alice_balance_token_1 = 1n) in
        "OK"
    in
    ()