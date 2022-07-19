
#import "../../contracts/factory/main.mligo" "Factory"
#import "../../contracts/auction/main.mligo" "Auction"
#import "bootstrap.mligo" "Bootstrap"
#import "../helpers/common.mligo" "Common_helper"
#import "../helpers/nft_multi.mligo" "NFT_MULTI_helper"

type fa2_storage = Factory.NFT_FA2.Storage.t
type ext = Factory.NFT_FA2.extension
type ext_fa2_storage = ext fa2_storage

type nft_multi_storage = NFT_MULTI_helper.NFT_MULTI.Storage.t
type ext_multi = NFT_MULTI_helper.NFT_MULTI.extension
type ext_nft_multi_storage = ext_multi nft_multi_storage

let test_first_bid_works =
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

    let _alice_create_auction_should_work = 
        let () = Test.log("_alice_create_auction_should_work") in
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
    let _bob_set_bid_order_should_work = 
        let () = Test.log("_bob_set_bid_order_should_work") in
        // retrieve FA2 address collection
        let fa2_nft_address : address = fa2_nft_originated.addr in
        let auction_storage : Auction.Storage.t = Test.get_storage auction_originated.taddr in
        let auction_balance_before : tez = Test.get_balance auction_originated.addr in
        //let () = Test.log(auction_balance_before) in

        // Set bid order 
        let param_bid : Auction.Parameter.set_bid_order_param = 0n in
        let () = Test.set_source bob in
        let _ = Test.transfer_to_contract_exn auction_originated.contr (SetBidOrder(param_bid) : Auction.parameter) 13mutez in
        
        // verify auction has been recorded in the storage
        let auction_storage_after : Auction.storage = Test.get_storage auction_originated.taddr in
        let _check_counter : unit = assert_with_error (auction_storage_after.nftSaleId=1n) "nftSaleId does not match expected value" in
        let found_auction_opt : Auction.Storage.nftauction option = Big_map.find_opt 0n auction_storage_after.auctionIdToAuction in
        let found_auction : Auction.Storage.nftauction = match found_auction_opt with
        | None -> (failwith("Unknown auction") : Auction.Storage.nftauction)
        | Some auct -> auct
        in

        // verify bob bid
        let _check_bidder_address : unit = assert_with_error (found_auction.bidderAddress=Some(bob)) "bob should be set as bidder address" in
        let _check_auction_price : unit = assert_with_error (found_auction.auctionPrice=13n) "auction price should be 13 mutez" in
        // verify balance
        let auction_balance_after : tez = Test.get_balance auction_originated.addr in
        //let () = Test.log(auction_balance_after) in
        let auction_balance_diff_opt : tez option = auction_balance_after - auction_balance_before in
        let auction_balance_diff : tez = match auction_balance_diff_opt with 
        | None -> failwith("Negative transfer !! ")
        | Some diff -> diff
        in
        let _check_transfer : unit = assert_with_error (auction_balance_diff = 13mutez) "Wrong amount transfered" in

        // verify NFT token still owned by auction
        let fa2_storage : ext_fa2_storage = Test.get_storage fa2_nft_originated.taddr in
        let auction_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage auction_originated.addr 1n in
        let _check_auction_ownership_of_token_1 : unit = assert(auction_balance_token_1 = 1n) in
        let alice_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage alice 1n in
        let _check_alice_ownership_of_token_1 : unit = assert(alice_balance_token_1 = 0n) in
        "OK"
    in
    ()

let test_set_bid_order_should_fail =
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

    let _alice_create_auction_should_work = 
        let () = Test.log("_alice_create_auction_should_work") in
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
        let _check_field : unit = assert_with_error (found_auction.nftAddress=param_set_nft.nftAddress) "does not match expected value" in
        let _check_field : unit = assert_with_error (found_auction.tokenId=param_set_nft.tokenId) "does not match expected value" in
        let _check_field : unit = assert_with_error (found_auction.reservePrice=param_set_nft.reservePrice) "does not match expected value" in
        let _check_field : unit = assert_with_error (found_auction.biddingPeriod=param_set_nft.auctionBiddingPeriod) "does not match expected value" in
        //let _check_field : unit = assert_with_error (found_auction.expirationTime=Some(Tezos.get_now() + int(param_set_nft.auctionExpirationPeriod))) "does not match expected value" in
        let _check_field : unit = assert_with_error (found_auction.assetClass=param_set_nft.assetClass) "does not match expected value" in

        // verify alice NFT token sent to auction contract
        let fa2_storage : ext_fa2_storage = Test.get_storage fa2_nft_originated.taddr in
        let auction_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage auction_originated.addr 1n in
        let _check_auction_ownership_of_token_1 : unit = assert(auction_balance_token_1 = 1n) in
        let alice_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage alice 1n in
        let _check_alice_ownership_of_token_1 : unit = assert(alice_balance_token_1 = 0n) in
        "OK"
    in
    let _bob_set_bid_order_with_no_amount_should_fail = 
        let () = Test.log("_bob_set_bid_order_with_no_amount_should_fail") in
        // retrieve FA2 address collection
        let fa2_nft_address : address = fa2_nft_originated.addr in
        let auction_storage : Auction.Storage.t = Test.get_storage auction_originated.taddr in

        // Set bid order 
        let param_bid : Auction.Parameter.set_bid_order_param = 0n in
        let () = Test.set_source bob in
        let fail_err = Test.transfer_to_contract auction_originated.contr (SetBidOrder(param_bid) : Auction.parameter) 0mutez in
        let () = Common_helper.assert_string_failure fail_err Auction.Errors.amount_lower_than_reserve_price in
        "OK"
    in
    ()

let test_second_bid_works =
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

    let _alice_create_auction_should_work = 
        let () = Test.log("_alice_create_auction_should_work") in
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
            auctionBiddingPeriod=30000n;
            auctionExpirationPeriod=1000000n;
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
        let _check_field : unit = assert_with_error (found_auction.nftAddress=param_set_nft.nftAddress) "does not match expected value" in
        let _check_field : unit = assert_with_error (found_auction.tokenId=param_set_nft.tokenId) "does not match expected value" in
        let _check_field : unit = assert_with_error (found_auction.reservePrice=param_set_nft.reservePrice) "does not match expected value" in
        let _check_field : unit = assert_with_error (found_auction.biddingPeriod=param_set_nft.auctionBiddingPeriod) "does not match expected value" in
        //let _check_field : unit = assert_with_error (found_auction.expirationTime=Some(Tezos.get_now() + int(param_set_nft.auctionExpirationPeriod))) "does not match expected value" in
        let _check_field : unit = assert_with_error (found_auction.assetClass=param_set_nft.assetClass) "does not match expected value" in

        // verify alice NFT token sent to auction contract
        let fa2_storage : ext_fa2_storage = Test.get_storage fa2_nft_originated.taddr in
        let auction_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage auction_originated.addr 1n in
        let _check_auction_ownership_of_token_1 : unit = assert(auction_balance_token_1 = 1n) in
        let alice_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage alice 1n in
        let _check_alice_ownership_of_token_1 : unit = assert(alice_balance_token_1 = 0n) in
        "OK"
    in
    let _bob_set_first_bid_order_should_work = 
        let () = Test.log("_bob_set_first_bid_order_should_work") in
        // retrieve FA2 address collection
        let fa2_nft_address : address = fa2_nft_originated.addr in
        let auction_storage : Auction.Storage.t = Test.get_storage auction_originated.taddr in
        let auction_balance_before : tez = Test.get_balance auction_originated.addr in
        //let () = Test.log(auction_balance_before) in

        // Set bid order 
        let param_bid : Auction.Parameter.set_bid_order_param = 0n in
        let () = Test.set_source bob in
        let _ = Test.transfer_to_contract_exn auction_originated.contr (SetBidOrder(param_bid) : Auction.parameter) 13mutez in
        
        // verify auction has been recorded in the storage
        let auction_storage_after : Auction.storage = Test.get_storage auction_originated.taddr in
        let _check_counter : unit = assert_with_error (auction_storage_after.nftSaleId=1n) "nftSaleId does not match expected value" in
        let found_auction_opt : Auction.Storage.nftauction option = Big_map.find_opt 0n auction_storage_after.auctionIdToAuction in
        let found_auction : Auction.Storage.nftauction = match found_auction_opt with
        | None -> (failwith("Unknown auction") : Auction.Storage.nftauction)
        | Some auct -> auct
        in

        // verify bob bid
        let _check_bidder_address : unit = assert_with_error (found_auction.bidderAddress=Some(bob)) "bob should be set as bidder address" in
        let _check_auction_price : unit = assert_with_error (found_auction.auctionPrice=13n) "auction price should be 13 mutez" in
        // verify balance
        let auction_balance_after : tez = Test.get_balance auction_originated.addr in
        //let () = Test.log(auction_balance_after) in
        let auction_balance_diff_opt : tez option = auction_balance_after - auction_balance_before in
        let auction_balance_diff : tez = match auction_balance_diff_opt with 
        | None -> failwith("Negative transfer !! ")
        | Some diff -> diff
        in
        let _check_transfer : unit = assert_with_error (auction_balance_diff = 13mutez) "Wrong amount transfered" in

        // verify NFT token still owned by auction
        let fa2_storage : ext_fa2_storage = Test.get_storage fa2_nft_originated.taddr in
        let auction_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage auction_originated.addr 1n in
        let _check_auction_ownership_of_token_1 : unit = assert(auction_balance_token_1 = 1n) in
        let alice_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage alice 1n in
        let _check_alice_ownership_of_token_1 : unit = assert(alice_balance_token_1 = 0n) in
        "OK"
    in
    let _frank_set_second_bid_order_should_work = 
        let () = Test.log("_frank_set_second_bid_order_should_work") in
        // retrieve FA2 address collection
        let fa2_nft_address : address = fa2_nft_originated.addr in
        let auction_storage_before : Auction.Storage.t = Test.get_storage auction_originated.taddr in
        let found_auction_opt_before : Auction.Storage.nftauction option = Big_map.find_opt 0n auction_storage_before.auctionIdToAuction in
        let found_auction_before : Auction.Storage.nftauction = match found_auction_opt_before with
        | None -> (failwith("Unknown auction") : Auction.Storage.nftauction)
        | Some auct -> auct
        in
        let previous_bidder = Option.unopt(found_auction_before.bidderAddress) in
        let previous_bidder_balance_before : tez = Test.get_balance previous_bidder in
        let auction_balance_before : tez = Test.get_balance auction_originated.addr in
        //let () = Test.log(auction_balance_before) in

        // Set bid order 
        let amount : tez = 23mutez in
        let param_bid : Auction.Parameter.set_bid_order_param = 0n in
        let () = Test.set_source frank in
        let _ = Test.transfer_to_contract_exn auction_originated.contr (SetBidOrder(param_bid) : Auction.parameter) amount in
        
        // verify auction has been recorded in the storage
        let auction_storage_after : Auction.storage = Test.get_storage auction_originated.taddr in
        let _check_counter : unit = assert_with_error (auction_storage_after.nftSaleId=1n) "nftSaleId does not match expected value" in
        let found_auction_opt : Auction.Storage.nftauction option = Big_map.find_opt 0n auction_storage_after.auctionIdToAuction in
        let found_auction : Auction.Storage.nftauction = match found_auction_opt with
        | None -> (failwith("Unknown auction") : Auction.Storage.nftauction)
        | Some auct -> auct
        in

        // verify frank bid
        let _check_bidder_address : unit = assert_with_error (found_auction.bidderAddress=Some(frank)) "bob should be set as bidder address" in
        //let () = Test.log(found_auction_before.auctionPrice + auction_storage_after.min_bp_bid) in
        //let () = Test.log(amount / 1mutez) in
        let _check_auction_price : unit = assert_with_error (found_auction_before.auctionPrice + auction_storage_after.min_bp_bid=amount / 1mutez) "auction price should be 23 mutez" in
        // verify balance
        let auction_balance_after : tez = Test.get_balance auction_originated.addr in
        //let () = Test.log(auction_balance_after) in
        let auction_balance_diff_opt : tez option = auction_balance_after - auction_balance_before in
        let auction_balance_diff : tez = match auction_balance_diff_opt with 
        | None -> failwith("Negative transfer !! ")
        | Some diff -> diff
        in

        // verify refund previous bidder
        let refund_amount_to_previous_bidder = 13mutez in
        let previous_bidder_balance_after : tez = Test.get_balance previous_bidder in
        let previous_bidder_balance_diff_opt = previous_bidder_balance_after - previous_bidder_balance_before in
        let previous_bidder_balance_diff : tez = match previous_bidder_balance_diff_opt with 
        | None -> failwith("Negative transfer !! ")
        | Some diff -> diff
        in
        let _check_transfer_refund : unit = assert_with_error (previous_bidder_balance_diff = refund_amount_to_previous_bidder) "Wrong amount refunded to previous bidder" in
       
        let _check_transfer : unit = assert_with_error (auction_balance_diff + refund_amount_to_previous_bidder = amount) "Wrong amount transfered" in

        // verify NFT token still owned by auction
        let fa2_storage : ext_fa2_storage = Test.get_storage fa2_nft_originated.taddr in
        let auction_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage auction_originated.addr 1n in
        let _check_auction_ownership_of_token_1 : unit = assert(auction_balance_token_1 = 1n) in
        let alice_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage alice 1n in
        let _check_alice_ownership_of_token_1 : unit = assert(alice_balance_token_1 = 0n) in
        "OK"
    in
    ()


let test_second_bid_wrong_amount_fails =
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

    let _alice_create_auction_should_work = 
        let () = Test.log("_alice_create_auction_should_work") in
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
            auctionBiddingPeriod=30000n;
            auctionExpirationPeriod=100000n;
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
        let _check_field : unit = assert_with_error (found_auction.nftAddress=param_set_nft.nftAddress) "does not match expected value" in
        let _check_field : unit = assert_with_error (found_auction.tokenId=param_set_nft.tokenId) "does not match expected value" in
        let _check_field : unit = assert_with_error (found_auction.reservePrice=param_set_nft.reservePrice) "does not match expected value" in
        let _check_field : unit = assert_with_error (found_auction.biddingPeriod=param_set_nft.auctionBiddingPeriod) "does not match expected value" in
        //let _check_field : unit = assert_with_error (found_auction.expirationTime=Some(Tezos.get_now() + int(param_set_nft.auctionExpirationPeriod))) "does not match expected value" in
        let _check_field : unit = assert_with_error (found_auction.assetClass=param_set_nft.assetClass) "does not match expected value" in

        // verify alice NFT token sent to auction contract
        let fa2_storage : ext_fa2_storage = Test.get_storage fa2_nft_originated.taddr in
        let auction_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage auction_originated.addr 1n in
        let _check_auction_ownership_of_token_1 : unit = assert(auction_balance_token_1 = 1n) in
        let alice_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage alice 1n in
        let _check_alice_ownership_of_token_1 : unit = assert(alice_balance_token_1 = 0n) in
        "OK"
    in
    let _bob_set_first_bid_order_should_work = 
        let () = Test.log("_bob_set_first_bid_order_should_work") in
        // retrieve FA2 address collection
        let fa2_nft_address : address = fa2_nft_originated.addr in
        let auction_storage : Auction.Storage.t = Test.get_storage auction_originated.taddr in
        let auction_balance_before : tez = Test.get_balance auction_originated.addr in
        //let () = Test.log(auction_balance_before) in

        // Set bid order 
        let param_bid : Auction.Parameter.set_bid_order_param = 0n in
        let () = Test.set_source bob in
        let _ = Test.transfer_to_contract_exn auction_originated.contr (SetBidOrder(param_bid) : Auction.parameter) 13mutez in
        
        // verify auction has been recorded in the storage
        let auction_storage_after : Auction.storage = Test.get_storage auction_originated.taddr in
        let _check_counter : unit = assert_with_error (auction_storage_after.nftSaleId=1n) "nftSaleId does not match expected value" in
        let found_auction_opt : Auction.Storage.nftauction option = Big_map.find_opt 0n auction_storage_after.auctionIdToAuction in
        let found_auction : Auction.Storage.nftauction = match found_auction_opt with
        | None -> (failwith("Unknown auction") : Auction.Storage.nftauction)
        | Some auct -> auct
        in


        // verify previous_bidder is still the last bidder
        let _check_bidder_address : unit = assert_with_error (found_auction.bidderAddress=Some(bob)) "bob should be set as bidder address" in
        let _check_auction_price : unit = assert_with_error (found_auction.auctionPrice=13n) "auction price should be 13 mutez" in
        // verify balance
        let auction_balance_after : tez = Test.get_balance auction_originated.addr in
        //let () = Test.log(auction_balance_after) in
        let auction_balance_diff_opt : tez option = auction_balance_after - auction_balance_before in
        let auction_balance_diff : tez = match auction_balance_diff_opt with 
        | None -> failwith("Negative transfer !! ")
        | Some diff -> diff
        in
        let _check_transfer : unit = assert_with_error (auction_balance_diff = 13mutez) "Wrong amount transfered" in

        // verify NFT token still owned by auction
        let fa2_storage : ext_fa2_storage = Test.get_storage fa2_nft_originated.taddr in
        let auction_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage auction_originated.addr 1n in
        let _check_auction_ownership_of_token_1 : unit = assert(auction_balance_token_1 = 1n) in
        let alice_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage alice 1n in
        let _check_alice_ownership_of_token_1 : unit = assert(alice_balance_token_1 = 0n) in
        "OK"
    in
    let _frank_set_second_bid_order_wrong_amount_should_fail = 
        let () = Test.log("_frank_set_second_bid_order_wrong_amount_should_fail") in
        // retrieve FA2 address collection
        let fa2_nft_address : address = fa2_nft_originated.addr in
        //let auction_storage : Auction.Storage.t = Test.get_storage auction_originated.taddr in
        let auction_storage_before : Auction.Storage.t = Test.get_storage auction_originated.taddr in
        let auction_balance_before : tez = Test.get_balance auction_originated.addr in
        let found_auction_opt_before : Auction.Storage.nftauction option = Big_map.find_opt 0n auction_storage_before.auctionIdToAuction in
        let found_auction_before : Auction.Storage.nftauction = match found_auction_opt_before with
        | None -> (failwith("Unknown auction") : Auction.Storage.nftauction)
        | Some auct -> auct
        in
        let previous_bidder = Option.unopt(found_auction_before.bidderAddress) in


        // Set bid order 
        let amount : tez = 15mutez in
        let param_bid : Auction.Parameter.set_bid_order_param = 0n in
        let () = Test.set_source frank in
        let fail_err = Test.transfer_to_contract auction_originated.contr (SetBidOrder(param_bid) : Auction.parameter) amount in
        let () = Common_helper.assert_string_failure fail_err Auction.Errors.bid_amount_too_low in

        // verify auction has been recorded in the storage
        let auction_storage_after : Auction.storage = Test.get_storage auction_originated.taddr in
        let _check_counter : unit = assert_with_error (auction_storage_after.nftSaleId=1n) "nftSaleId does not match expected value" in
        let found_auction_opt : Auction.Storage.nftauction option = Big_map.find_opt 0n auction_storage_after.auctionIdToAuction in
        let found_auction : Auction.Storage.nftauction = match found_auction_opt with
        | None -> (failwith("Unknown auction") : Auction.Storage.nftauction)
        | Some auct -> auct
        in

        // verify previous_bidder is still the last bidder
        let _check_bidder_address : unit = assert_with_error (found_auction.bidderAddress=Some(bob)) "bob should be set as bidder address" in

        // verify balance
        let auction_balance_after : tez = Test.get_balance auction_originated.addr in
        //let () = Test.log(auction_balance_after) in
        let auction_balance_diff_opt : tez option = auction_balance_after - auction_balance_before in
        let auction_balance_diff : tez = match auction_balance_diff_opt with 
        | None -> failwith("Negative transfer !! ")
        | Some diff -> diff
        in
        let _check_transfer : unit = assert_with_error (auction_balance_diff = 0mutez) "Wrong amount transfered" in

        // verify NFT token still owned by auction
        let fa2_storage : ext_fa2_storage = Test.get_storage fa2_nft_originated.taddr in
        let auction_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage auction_originated.addr 1n in
        let _check_auction_ownership_of_token_1 : unit = assert(auction_balance_token_1 = 1n) in
        let alice_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage alice 1n in
        let _check_alice_ownership_of_token_1 : unit = assert(alice_balance_token_1 = 0n) in
        "OK"
    in
    ()



let test_second_bid_twice_fails =
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

    let _alice_create_auction_should_work = 
        let () = Test.log("_alice_create_auction_should_work") in
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
            auctionBiddingPeriod=30000n;
            auctionExpirationPeriod=100000n;
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
        let _check_field : unit = assert_with_error (found_auction.nftAddress=param_set_nft.nftAddress) "does not match expected value" in
        let _check_field : unit = assert_with_error (found_auction.tokenId=param_set_nft.tokenId) "does not match expected value" in
        let _check_field : unit = assert_with_error (found_auction.reservePrice=param_set_nft.reservePrice) "does not match expected value" in
        let _check_field : unit = assert_with_error (found_auction.biddingPeriod=param_set_nft.auctionBiddingPeriod) "does not match expected value" in
        //let _check_field : unit = assert_with_error (found_auction.expirationTime=Some(Tezos.get_now() + int(param_set_nft.auctionExpirationPeriod))) "does not match expected value" in
        let _check_field : unit = assert_with_error (found_auction.assetClass=param_set_nft.assetClass) "does not match expected value" in

        // verify alice NFT token sent to auction contract
        let fa2_storage : ext_fa2_storage = Test.get_storage fa2_nft_originated.taddr in
        let auction_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage auction_originated.addr 1n in
        let _check_auction_ownership_of_token_1 : unit = assert(auction_balance_token_1 = 1n) in
        let alice_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage alice 1n in
        let _check_alice_ownership_of_token_1 : unit = assert(alice_balance_token_1 = 0n) in
        "OK"
    in
    let _bob_set_first_bid_order_should_work = 
        let () = Test.log("_bob_set_first_bid_order_should_work") in
        // retrieve FA2 address collection
        let fa2_nft_address : address = fa2_nft_originated.addr in
        let auction_storage : Auction.Storage.t = Test.get_storage auction_originated.taddr in
        let auction_balance_before : tez = Test.get_balance auction_originated.addr in
        //let () = Test.log(auction_balance_before) in

        // Set bid order 
        let param_bid : Auction.Parameter.set_bid_order_param = 0n in
        let () = Test.set_source bob in
        let _ = Test.transfer_to_contract_exn auction_originated.contr (SetBidOrder(param_bid) : Auction.parameter) 13mutez in
        
        // verify auction has been recorded in the storage
        let auction_storage_after : Auction.storage = Test.get_storage auction_originated.taddr in
        let _check_counter : unit = assert_with_error (auction_storage_after.nftSaleId=1n) "nftSaleId does not match expected value" in
        let found_auction_opt : Auction.Storage.nftauction option = Big_map.find_opt 0n auction_storage_after.auctionIdToAuction in
        let found_auction : Auction.Storage.nftauction = match found_auction_opt with
        | None -> (failwith("Unknown auction") : Auction.Storage.nftauction)
        | Some auct -> auct
        in

        // verify bob bid
        let _check_bidder_address : unit = assert_with_error (found_auction.bidderAddress=Some(bob)) "bob should be set as bidder address" in
        let _check_auction_price : unit = assert_with_error (found_auction.auctionPrice=13n) "auction price should be 13 mutez" in
        // verify balance
        let auction_balance_after : tez = Test.get_balance auction_originated.addr in
        //let () = Test.log(auction_balance_after) in
        let auction_balance_diff_opt : tez option = auction_balance_after - auction_balance_before in
        let auction_balance_diff : tez = match auction_balance_diff_opt with 
        | None -> failwith("Negative transfer !! ")
        | Some diff -> diff
        in
        let _check_transfer : unit = assert_with_error (auction_balance_diff = 13mutez) "Wrong amount transfered" in

        // verify NFT token still owned by auction
        let fa2_storage : ext_fa2_storage = Test.get_storage fa2_nft_originated.taddr in
        let auction_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage auction_originated.addr 1n in
        let _check_auction_ownership_of_token_1 : unit = assert(auction_balance_token_1 = 1n) in
        let alice_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage alice 1n in
        let _check_alice_ownership_of_token_1 : unit = assert(alice_balance_token_1 = 0n) in
        "OK"
    in
    let _bob_set_second_bid_order_should_work = 
        let () = Test.log("_bob_set_second_bid_order_should_work") in
        // retrieve FA2 address collection
        let fa2_nft_address : address = fa2_nft_originated.addr in
        let auction_storage_before : Auction.Storage.t = Test.get_storage auction_originated.taddr in
        let auction_balance_before : tez = Test.get_balance auction_originated.addr in
        let found_auction_opt_before : Auction.Storage.nftauction option = Big_map.find_opt 0n auction_storage_before.auctionIdToAuction in
        let found_auction_before : Auction.Storage.nftauction = match found_auction_opt_before with
        | None -> (failwith("Unknown auction") : Auction.Storage.nftauction)
        | Some auct -> auct
        in
        let previous_bidder = Option.unopt(found_auction_before.bidderAddress) in

        // Set bid order 
        let amount : tez = 23mutez in
        let param_bid : Auction.Parameter.set_bid_order_param = 0n in
        let () = Test.set_source bob in
        let fail_err = Test.transfer_to_contract auction_originated.contr (SetBidOrder(param_bid) : Auction.parameter) amount in
        let () = Common_helper.assert_string_failure fail_err Auction.Errors.cannot_bid_twice in

        // verify auction has been recorded in the storage
        let auction_storage_after : Auction.storage = Test.get_storage auction_originated.taddr in
        let _check_counter : unit = assert_with_error (auction_storage_after.nftSaleId=1n) "nftSaleId does not match expected value" in
        let found_auction_opt : Auction.Storage.nftauction option = Big_map.find_opt 0n auction_storage_after.auctionIdToAuction in
        let found_auction : Auction.Storage.nftauction = match found_auction_opt with
        | None -> (failwith("Unknown auction") : Auction.Storage.nftauction)
        | Some auct -> auct
        in

        // verify previous_bidder is still the last bidder
        let _check_bidder_address : unit = assert_with_error (found_auction.bidderAddress=Some(previous_bidder)) "bob should be set as bidder address" in
        
        // TO DO ???
        //let _check_auction_price : unit = assert_with_error (found_auction.auctionPrice=amount / 1mutez) "auction price should be 15 mutez" in
        
        
        // verify balance
        let auction_balance_after : tez = Test.get_balance auction_originated.addr in
        //let () = Test.log(auction_balance_after) in
        let auction_balance_diff_opt : tez option = auction_balance_after - auction_balance_before in
        let auction_balance_diff : tez = match auction_balance_diff_opt with 
        | None -> failwith("Negative transfer !! ")
        | Some diff -> diff
        in
        let _check_transfer : unit = assert_with_error (auction_balance_diff = 0mutez) "Wrong amount transfered" in

        // verify NFT token still owned by auction
        let fa2_storage : ext_fa2_storage = Test.get_storage fa2_nft_originated.taddr in
        let auction_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage auction_originated.addr 1n in
        let _check_auction_ownership_of_token_1 : unit = assert(auction_balance_token_1 = 1n) in
        let alice_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage alice 1n in
        let _check_alice_ownership_of_token_1 : unit = assert(alice_balance_token_1 = 0n) in
        "OK"
    in
    ()


let test_first_bid_nft_multi_works =
    // ARRANGE
    let (alice, bob, reserve, royalties, admin, frank, baker, accountZero, accountOne) = Bootstrap.bootstrap_accounts(("2022-01-01T00:22:10Z" : timestamp)) in
    let () = Test.set_baker_policy (By_account baker) in

    // originate FA2 NFT semi-fungible smart contract
    let nft_multi_init_ledger : ((address * nat), nat)map = Map.literal[((alice, 1n), 1000n); ((bob, 2n), 1000n)] in    
    let nft_multi_totalsupply : (nat, nat) map = Map.literal[(1n, 1000n); (2n, 1000n)] in 
    let nft_multi_originated = Bootstrap.bootstrap_fa2_MULTI_NFT(alice, frank, [1n; 2n], nft_multi_totalsupply, nft_multi_init_ledger) in 

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


    let _alice_create_auction_should_work = 
        let () = Test.log("_alice_create_auction_should_work") in
        // retrieve FA2 address collection
        let nft_multi_address : address = nft_multi_originated.addr in
        //let fa2_nft_address : address = fa2_nft_originated.addr in
        let auction_storage : Auction.Storage.t = Test.get_storage auction_originated.taddr in

        // APPROVE marketplace to transfer token 1
        let () = Test.set_source alice in
        let fa2_contract : NFT_MULTI_helper.NFT_MULTI.parameter contract = Test.to_contract nft_multi_originated.taddr in
        let update_op : Factory.NFT_FA2.NFT.update_operators = [(Add_operator({owner=alice; operator=auction_originated.addr; token_id=1n}) : NFT_MULTI_helper.NFT_MULTI.NFT.unit_update)] in
        let _ = Test.transfer_to_contract_exn fa2_contract (Update_operators(update_op) : NFT_MULTI_helper.NFT_MULTI.parameter) 0mutez in

        // Set NFT 
        let param_set_nft : Auction.Parameter.set_nft_auction_param = {
            nftAddress=nft_multi_address;
            tokenId=1n;
            reservePrice=12n;
            auctionBiddingPeriod=100n;
            auctionExpirationPeriod=1000n;
            assetClass=NFT_MULTI;
            tokenAmount=2n;
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
        let _check_field : unit = assert_with_error (found_auction.nftAddress=nft_multi_address) "does not match expected value" in
        let _check_field : unit = assert_with_error (found_auction.tokenId=1n) "does not match expected value" in
        let _check_field : unit = assert_with_error (found_auction.reservePrice=12n) "does not match expected value" in
        let _check_field : unit = assert_with_error (found_auction.biddingPeriod=100n) "does not match expected value" in
        //let _check_field : unit = assert_with_error (found_auction.expirationTime=Some(Tezos.get_now() + int(param_set_nft.auctionExpirationPeriod))) "does not match expected value" in
        let _check_field : unit = assert_with_error (found_auction.assetClass=NFT_MULTI) "does not match expected value" in

        // verify alice NFT token sent to auction contract
        let fa2_storage : ext_nft_multi_storage = Test.get_storage nft_multi_originated.taddr in
        let auction_balance_token_1 = NFT_MULTI_helper.NFT_MULTI.NFT.Storage.get_balance fa2_storage auction_originated.addr 1n in
        let _check_auction_ownership_of_token_1 : unit = assert(auction_balance_token_1 = 2n) in
        let alice_balance_token_1 = NFT_MULTI_helper.NFT_MULTI.NFT.Storage.get_balance fa2_storage alice 1n in
        let _check_alice_ownership_of_token_1 : unit = assert(alice_balance_token_1 = 998n) in
        "OK"
    in
    let _bob_set_bid_order_on_nft_multi_should_work = 
        let () = Test.log("_bob_set_bid_order_on_nft_multi_should_work") in
        let buyer_payment_amount = 13mutez in
        // retrieve auction balance
        let auction_storage : Auction.Storage.t = Test.get_storage auction_originated.taddr in
        let auction_balance_before : tez = Test.get_balance auction_originated.addr in

        // Set bid order 
        let param_bid : Auction.Parameter.set_bid_order_param = 0n in
        let () = Test.set_source bob in
        let _ = Test.transfer_to_contract_exn auction_originated.contr (SetBidOrder(param_bid) : Auction.parameter) buyer_payment_amount in
        
        // verify auction has been recorded in the storage
        let auction_storage_after : Auction.storage = Test.get_storage auction_originated.taddr in
        let _check_counter : unit = assert_with_error (auction_storage_after.nftSaleId=1n) "nftSaleId does not match expected value" in
        let found_auction_opt : Auction.Storage.nftauction option = Big_map.find_opt 0n auction_storage_after.auctionIdToAuction in
        let found_auction : Auction.Storage.nftauction = match found_auction_opt with
        | None -> (failwith("Unknown auction") : Auction.Storage.nftauction)
        | Some auct -> auct
        in

        // verify bob bid
        let _check_bidder_address : unit = assert_with_error (found_auction.bidderAddress=Some(bob)) "bob should be set as bidder address" in
        let _check_auction_price : unit = assert_with_error (found_auction.auctionPrice=buyer_payment_amount / 1mutez) "auction price should be 13 mutez" in
        // verify balance
        let auction_balance_after : tez = Test.get_balance auction_originated.addr in
        let auction_balance_diff_opt : tez option = auction_balance_after - auction_balance_before in
        let auction_balance_diff : tez = match auction_balance_diff_opt with 
        | None -> failwith("Negative transfer !! ")
        | Some diff -> diff
        in
        let _check_transfer : unit = assert_with_error (auction_balance_diff = buyer_payment_amount) "Wrong amount transfered" in

        // verify NFT token still owned by auction
        let fa2_storage : ext_nft_multi_storage = Test.get_storage nft_multi_originated.taddr in
        let auction_balance_token_1 = NFT_MULTI_helper.NFT_MULTI.NFT.Storage.get_balance fa2_storage auction_originated.addr 1n in
        let _check_auction_ownership_of_token_1 : unit = assert(auction_balance_token_1 = 2n) in
        let alice_balance_token_1 = NFT_MULTI_helper.NFT_MULTI.NFT.Storage.get_balance fa2_storage alice 1n in
        let _check_alice_ownership_of_token_1 : unit = assert(alice_balance_token_1 = 998n) in
        "OK"
    in
    ()