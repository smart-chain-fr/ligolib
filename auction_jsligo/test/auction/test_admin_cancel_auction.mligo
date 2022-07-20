
#import "../contracts/factory/main.mligo" "Factory"
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

let test_admin_cancel_alice_auction =
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

    let create_auction_helper = 
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
    let _admin_cancel_auction_should_work = 
        let () = Test.log("_admin_cancel_auction_should_work") in
        // retrieve FA2 address collection
        let fa2_nft_address : address = fa2_nft_originated.addr in
        let auction_storage : Auction.Storage.t = Test.get_storage auction_originated.taddr in

        // Admin successfully cancel auction 
        let param_admin_cancel : Auction.Parameter.admin_cancel_nft_auction_param = {
            saleId=0n;
            reason="because";
        } in
        let () = Test.set_source auction_storage.admin in
        let _ = Test.transfer_to_contract_exn auction_originated.contr (AdminCancelNftAuction(param_admin_cancel) : Auction.parameter) 0mutez in
        
        // verify auction has been recorded in the storage
        let auction_storage_after : Auction.storage = Test.get_storage auction_originated.taddr in
        let _check_counter : unit = assert_with_error (auction_storage_after.nftSaleId=1n) "nftSaleId does not match expected value" in
        let found_auction_opt : Auction.Storage.nftauction option = Big_map.find_opt 0n auction_storage_after.auctionIdToAuction in
        let is_auction_removed : bool = match found_auction_opt with
        | None -> true
        | Some auct -> failwith("auction 0 should not exist")
        in
        let _check_auction_removed : unit = assert_with_error (is_auction_removed) "Auction has not been removed" in

        // verify NFT token sent back to alice
        let fa2_storage : ext_fa2_storage = Test.get_storage fa2_nft_originated.taddr in
        let auction_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage auction_originated.addr 1n in
        let _check_auction_ownership_of_token_1 : unit = assert(auction_balance_token_1 = 0n) in
        let alice_balance_token_1 = Factory.NFT_FA2.Storage.get_balance fa2_storage alice 1n in
        let _check_alice_ownership_of_token_1 : unit = assert(alice_balance_token_1 = 1n) in
        "OK"
    in
    ()

let test_admin_fails_to_cancel_no_reason =
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

    let create_auction_helper = 
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
        "OK"
    in
    let _admin_cancel_auction_no_reason_should_fail = 
        let () = Test.log("_admin_cancel_auction_no_reason_should_fail") in

        let auction_storage : Auction.Storage.t = Test.get_storage auction_originated.taddr in

        // Admin successfully cancel auction 
        let param_admin_cancel : Auction.Parameter.admin_cancel_nft_auction_param = {
            saleId=0n;
            reason="";
        } in
        let () = Test.set_source auction_storage.admin in
        let fail_err = Test.transfer_to_contract auction_originated.contr (AdminCancelNftAuction(param_admin_cancel) : Auction.parameter) 0mutez in
        let () = Common_helper.assert_string_failure fail_err Auction.Errors.no_reason in
        "OK"
    in
    ()

let test_admin_fails_to_cancel_wrong_auction_id =
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

    let create_auction_helper = 
        //let () = Test.log("_alice_create_auction_should_work") in
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
        "OK"
    in
    let _admin_cancel_auction_wrong_id_should_fail = 
        let () = Test.log("_admin_cancel_auction_wrong_id_should_fail") in

        let auction_storage : Auction.Storage.t = Test.get_storage auction_originated.taddr in

        // Admin successfully cancel auction 
        let param_admin_cancel : Auction.Parameter.admin_cancel_nft_auction_param = {
            saleId=1n;
            reason="because";
        } in
        let () = Test.set_source auction_storage.admin in
        let fail_err = Test.transfer_to_contract auction_originated.contr (AdminCancelNftAuction(param_admin_cancel) : Auction.parameter) 0mutez in
        let () = Common_helper.assert_string_failure fail_err Auction.Errors.unknown_auction_id in
        "OK"
    in
    ()

let test_admin_fails_to_cancel_wrong_sender =
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

    let create_auction_helper = 
        //let () = Test.log("_alice_create_auction_should_work") in
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
        "OK"
    in
    let _admin_cancel_auction_wrong_sender_should_fail = 
        let () = Test.log("_admin_cancel_auction_wrong_sender_should_fail") in

        let auction_storage : Auction.Storage.t = Test.get_storage auction_originated.taddr in

        // Admin successfully cancel auction 
        let param_admin_cancel : Auction.Parameter.admin_cancel_nft_auction_param = {
            saleId=0n;
            reason="because";
        } in
        let () = Test.set_source alice in
        let fail_err = Test.transfer_to_contract auction_originated.contr (AdminCancelNftAuction(param_admin_cancel) : Auction.parameter) 0mutez in
        let () = Common_helper.assert_string_failure fail_err Auction.Errors.not_admin in
        "OK"
    in
    ()


let test_admin_cancel_nft_multi_should_work =
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

    let _alice_create_auction_with_nft_multi_should_work = 
        let () = Test.log("_alice_create_auction_with_nft_multi_should_work") in
        // retrieve FA2 address collection
        let nft_multi_address : address = nft_multi_originated.addr in
        let auction_storage : Auction.Storage.t = Test.get_storage auction_originated.taddr in

        // APPROVE marketplace to transfer token 1
        let () = Test.set_source alice in
        let fa2_contract : NFT_MULTI_helper.NFT_MULTI.parameter contract = Test.to_contract nft_multi_originated.taddr in
        let update_op : NFT_MULTI_helper.NFT_MULTI.NFT.update_operators = [(Add_operator({owner=alice; operator=auction_originated.addr; token_id=1n}) : NFT_MULTI_helper.NFT_MULTI.NFT.unit_update)] in
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
    let _admin_cancel_auction_nft_multi_should_work = 
        let () = Test.log("_admin_cancel_auction_nft_multi_should_work") in
        // retrieve FA2 address collection
        let auction_storage : Auction.Storage.t = Test.get_storage auction_originated.taddr in

        // Admin successfully cancel auction 
        let param_admin_cancel : Auction.Parameter.admin_cancel_nft_auction_param = {
            saleId=0n;
            reason="because";
        } in
        let () = Test.set_source auction_storage.admin in
        let _ = Test.transfer_to_contract_exn auction_originated.contr (AdminCancelNftAuction(param_admin_cancel) : Auction.parameter) 0mutez in
        
        // verify auction has been recorded in the storage
        let auction_storage_after : Auction.storage = Test.get_storage auction_originated.taddr in
        let _check_counter : unit = assert_with_error (auction_storage_after.nftSaleId=1n) "nftSaleId does not match expected value" in
        let found_auction_opt : Auction.Storage.nftauction option = Big_map.find_opt 0n auction_storage_after.auctionIdToAuction in
        let is_auction_removed : bool = match found_auction_opt with
        | None -> true
        | Some auct -> failwith("auction 0 should not exist")
        in
        let _check_auction_removed : unit = assert_with_error (is_auction_removed) "Auction has not been removed" in

        // verify NFT token sent back to alice
        let fa2_storage : ext_nft_multi_storage = Test.get_storage nft_multi_originated.taddr in
        let auction_balance_token_1 = NFT_MULTI_helper.NFT_MULTI.NFT.Storage.get_balance fa2_storage auction_originated.addr 1n in
        let _check_auction_ownership_of_token_1 : unit = assert(auction_balance_token_1 = 0n) in
        let alice_balance_token_1 = NFT_MULTI_helper.NFT_MULTI.NFT.Storage.get_balance fa2_storage alice 1n in
        let _check_alice_ownership_of_token_1 : unit = assert(alice_balance_token_1 = 1000n) in
        "OK"
    in
    ()