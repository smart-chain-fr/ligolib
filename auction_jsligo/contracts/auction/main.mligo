#import "storage.jsligo" "Storage"
#import "errors.jsligo" "Errors"
#import "parameter.jsligo" "Parameter"
#import "common.jsligo" "Common"
#import "assert.jsligo" "Assert"

type storage = Storage.t
type parameter = Parameter.t
type return = operation list * storage


let setCommissionFee(param, store : Parameter.set_fee_param * Storage.t) : return =
    let _check_admin : unit = Assert.assert_only_admin store in
    let _check_between_0_and_100 : unit = assert_with_error (param >= 0n && param <= 100n) Errors.not_between_0_and_100 in
    (([] : operation list), { store with commissionFee=param })

let setReserveAddress(param, store : Parameter.set_reserve_param * Storage.t) : return =
    let _check_admin : unit = Assert.assert_only_admin store in
    (([] : operation list), { store with reserveAddress=param })

let setRoyaltiesStorageAddress(param, store : Parameter.set_royalties_param * Storage.t) : return =
    let _check_admin : unit = Assert.assert_only_admin store in
    (([] : operation list), { store with royaltiesStorage=param })

let emergencyPause(param, store : Parameter.pause_param * Storage.t) : return =
    let _check_admin : unit = Assert.assert_only_admin store in
    (([] : operation list), { store with isPaused=param })

let setBidOrder(param, store : Parameter.set_bid_order_param * Storage.t) : return =
    let sender = Tezos.get_sender() in
    let _check_is_not_paused : unit = Assert.assert_is_not_paused store in
    let currentAuction : Storage.nftauction = match Big_map.find_opt param store.auctionIdToAuction with
    | None -> failwith(Errors.unknown_auction_id)
    | Some x -> x 
    in
    let _check_reserve_auction : unit = Assert.assert_auction_reserve_price_not_zero currentAuction in
    // case first bid
    let _check_is_not_expired : unit = Assert.assert_is_not_expired currentAuction in
    let tx_amount = Tezos.get_amount() in 
    let tx_sender = Tezos.get_sender() in
    let tx_now = Tezos.get_now() in
    let modified_auctions, operations = 
        if (currentAuction.endTime = (None : timestamp option)) then
            let _check_amount_higher_than_reserve_price : unit = assert_with_error (currentAuction.reservePrice * 1mutez <= tx_amount) Errors.amount_lower_than_reserve_price in
            let modified_endtime = Some(tx_now + int(currentAuction.biddingPeriod)) in
            let modified_auction = { currentAuction with auctionPrice=tx_amount / 1mutez; bidderAddress=Some(tx_sender); endTime = modified_endtime } in
            (Big_map.update param (Some(modified_auction)) store.auctionIdToAuction, ([] : operation list))
        else
            // case not first bid
            let _check_auction_is_over : unit = Assert.assert_auction_is_not_over(currentAuction) in
            let _check_auction_no_double_bid : unit = Assert.assert_no_twice_bidding(currentAuction) in
            let _check_assert_bid_is_enough : unit = Assert.assert_bid_is_enough(currentAuction, store) in
            let modified_endtime = if (Option.unopt(currentAuction.endTime) < tx_now + int(store.extension_duration)) then
                Some(tx_now + int(store.extension_duration)) 
            else
                currentAuction.endTime
            in
            let modified_auction = { currentAuction with auctionPrice=tx_amount / 1mutez; bidderAddress=Some(tx_sender); endTime = modified_endtime } in
            let old_bidder = match currentAuction.bidderAddress with
                | None -> failwith(Errors.missing_bidder_address)
                | Some addr -> addr
            in
            let old_amount = currentAuction.auctionPrice in
            let destination : unit contract = match (Tezos.get_contract_opt(old_bidder) : unit contract option) with 
            | None -> (failwith(Errors.missing_contract_bidder_address) : unit contract)
            | Some dest -> dest
            in
            let op : operation = Tezos.transaction unit (old_amount * 1mutez) destination in
            let ops : operation list = [ op ] in
            (Big_map.update param (Some(modified_auction)) store.auctionIdToAuction, ops)
    in
    (operations, { store with auctionIdToAuction=modified_auctions })

let finalizeAuction(param, store : Parameter.finalize_auction_param * Storage.t) : return =
    let currentAuction : Storage.nftauction = match Big_map.find_opt param store.auctionIdToAuction with
    | None -> failwith(Errors.unknown_auction_id)
    | Some x -> x
    in
    let _check_auction_not_started : unit = Assert.assert_auction_is_started currentAuction in
    let _check_auction_not_ended : unit = Assert.assert_auction_is_not_ended currentAuction in

    let modified_auctions = Big_map.remove param store.auctionIdToAuction in

    let bidderAddress : address = match currentAuction.bidderAddress with
    | None -> (failwith(Errors.missing_bidder_address) : address)
    | Some addr -> addr
    in
    let op_nft : operation = Common.transferAsset(
        currentAuction.assetClass,
        currentAuction.nftAddress,
        bidderAddress,
        currentAuction.tokenId,
        currentAuction.tokenAmount
    ) in

    let _check_fee : unit = assert_with_error (store.commissionFee <= 10000n) Errors.fee_out_of_bound in
    let fee = (currentAuction.auctionPrice * store.commissionFee) / 10000n in
    let amountLeft = abs(currentAuction.auctionPrice - fee) in
    //let () = failwith(fee) in
    //let () = failwith(amountLeft) in
    let destination_fee : unit contract = match (Tezos.get_contract_opt(store.reserveAddress) : unit contract option) with 
    | None -> (failwith(Errors.missing_contract_reserve_address) : unit contract)
    | Some dest -> dest
    in
    let op_fee : operation = Tezos.transaction unit (fee * 1mutez) destination_fee in
    let destination_seller : unit contract = match (Tezos.get_contract_opt(currentAuction.sellerAddress) : unit contract option) with 
    | None -> (failwith(Errors.missing_contract_seller_address) : unit contract)
    | Some dest -> dest
    in
    let op_seller : operation = Tezos.transaction unit (amountLeft * 1mutez) destination_seller in

    let ops : operation list = [ op_seller; op_nft; op_fee; ] in 

// handle royalties
//         uint256[] memory royaltyFee_;
//         address[] memory royaltyRecipient_;

//         (royaltyFee_, royaltyRecipient_) = IRoyaltiesStorage(royaltiesStorage)
//             .getRoyalties(nftSale_.nftAddress, nftSale_.tokenId);

//         amountLeft = executeRoyaltyTransfers(
//             royaltyFee_,
//             royaltyRecipient_,
//             nftSale_.auctionPrice,
//             amountLeft
//         );

    (ops, { store with auctionIdToAuction=modified_auctions })

let setNftAuction(param, store : Parameter.set_nft_auction_param * Storage.t) : return =
    let sender = Tezos.get_sender() in
    let _check_is_not_paused : unit = Assert.assert_is_not_paused store in
    let _check_nft_address : unit = Assert.assert_nft_contract_exist(param.nftAddress, param.assetClass) in
    let _check_bidding_period_not_zero : unit = Assert.assert_bidding_period_not_zero param.auctionBiddingPeriod in
    let _check_expiration_period_not_zero : unit = Assert.assert_expiration_period_not_zero param.auctionExpirationPeriod in
    let _check_reserve_price_not_zero : unit = Assert.assert_reserve_price_not_zero param.reservePrice in

    let op : operation = Common.transferAssetToAuctionContract(param.assetClass, param.nftAddress, param.tokenId, Tezos.get_sender(), Tezos.get_self_address(), param.tokenAmount) in
    let ops : operation list = [op] in
    let expirationtimestamp : timestamp = Tezos.get_now() + int(param.auctionExpirationPeriod) in
    let new_auction : Storage.nftauction = {
        saleId=store.nftSaleId;
        nftAddress=param.nftAddress;
        tokenId=param.tokenId;
        sellerAddress=Tezos.get_sender();
        bidderAddress=(None : address option);
        reservePrice=param.reservePrice;
        auctionPrice=0n;
        biddingPeriod=param.auctionBiddingPeriod;
        expirationTime=Some(expirationtimestamp);
        endTime=(None : timestamp option);
        assetClass=param.assetClass;
        tokenAmount=param.tokenAmount;
    } in
    let modified_auctions = Big_map.add store.nftSaleId new_auction store.auctionIdToAuction in
    (ops, { store with auctionIdToAuction=modified_auctions; nftSaleId=store.nftSaleId + 1n })

let cancelNftAuction(param, store : Parameter.cancel_nft_auction_param * Storage.t) : return =
    let sender = Tezos.get_sender() in
    let _check_is_not_paused : unit = Assert.assert_is_not_paused store in
    let currentAuction : Storage.nftauction = match Big_map.find_opt param store.auctionIdToAuction with
    | None -> failwith(Errors.unknown_auction_id)
    | Some x -> x
    in
    let _check_sender_owns_auction : unit = assert_with_error (sender = currentAuction.sellerAddress) Errors.not_owner_auction in
    let _check_auction_not_started : unit = Assert.assert_auction_is_not_started currentAuction in

    let modified_auctions = Big_map.remove param store.auctionIdToAuction in
    let op_nft : operation = Common.transferAsset(
            currentAuction.assetClass,
            currentAuction.nftAddress,
            currentAuction.sellerAddress,
            currentAuction.tokenId,
            currentAuction.tokenAmount
        ) in
    let ops : operation list = [ op_nft ] in
    (ops, { store with auctionIdToAuction=modified_auctions })

let adminCancelNftAuction(param, store : Parameter.admin_cancel_nft_auction_param * Storage.t) : return =
    let _check_admin : unit = Assert.assert_only_admin store in
    let _check_reason : unit = Assert.assert_reason_is_given param.reason in
    let currentAuction : Storage.nftauction = match Big_map.find_opt param.saleId store.auctionIdToAuction with
    | None -> failwith(Errors.unknown_auction_id)
    | Some x -> x
    in
    let _check_reserve_price : unit = Assert.assert_auction_reserve_price_not_zero currentAuction in
    let modified_auctions = Big_map.remove param.saleId store.auctionIdToAuction in

    let op_nft : operation = Common.transferAsset(
            currentAuction.assetClass,
            currentAuction.nftAddress,
            currentAuction.sellerAddress,
            currentAuction.tokenId,
            currentAuction.tokenAmount
        ) in
    let ops : operation list = [ op_nft ] in
    let ops = if (currentAuction.auctionPrice <> 0n) then
            let bidderAddress : address = match currentAuction.bidderAddress with
            | None -> (failwith(Errors.missing_bidder_address) : address)
            | Some addr -> addr
            in
            let destination : unit contract = match (Tezos.get_contract_opt(bidderAddress) : unit contract option) with 
            | None -> (failwith(Errors.missing_contract_bidder_address) : unit contract)
            | Some dest -> dest
            in
             let op : operation = Tezos.transaction unit (currentAuction.auctionPrice * 1mutez) destination in
             op :: ops
        else
            ops
    in
    (ops, { store with auctionIdToAuction=modified_auctions })

let updateNftAuctionPeriods(param, store : Parameter.update_periods_param * Storage.t) : return =
    let sender = Tezos.get_sender() in
    let _check_is_not_paused : unit = Assert.assert_is_not_paused store in
    let _check_bidding_period_not_zero : unit = Assert.assert_bidding_period_not_zero param.auctionBiddingPeriod in
    let currentAuction : Storage.nftauction = match Big_map.find_opt param.saleId store.auctionIdToAuction with
    | None -> failwith(Errors.unknown_auction_id)
    | Some x -> x
    in
    let _check_sender_owns_auction : unit = assert_with_error (sender = currentAuction.sellerAddress) Errors.not_owner_auction in
    let _check_auction_not_started : unit = Assert.assert_auction_is_not_started currentAuction in

    // TO-DO: instead of adding `Tezos.get_now()`, we could instead add the previous `expirationTime`
    let modified_auction = { currentAuction with biddingPeriod=param.auctionBiddingPeriod; expirationTime=(Some(Tezos.get_now() + int(param.auctionExpirationPeriod))) } in
    let modified_auctions = Big_map.update param.saleId (Some(modified_auction)) store.auctionIdToAuction in
    (([] : operation list), { store with auctionIdToAuction=modified_auctions })

let updateReservePriceNftAuction(param, store : Parameter.update_price_param * Storage.t) : return =
    let sender = Tezos.get_sender() in
    let _check_is_not_paused : unit = Assert.assert_is_not_paused store in
    let _check_reserve_price_not_zero : unit = Assert.assert_reserve_price_not_zero param.reservePrice in
    let currentAuction : Storage.nftauction = match Big_map.find_opt param.saleId store.auctionIdToAuction with
    | None -> failwith(Errors.unknown_auction_id)
    | Some x -> x
    in
    let _check_sender_owns_auction : unit = assert_with_error (sender = currentAuction.sellerAddress) Errors.not_owner_auction in
    let _check_auction_not_started : unit = Assert.assert_auction_is_not_started currentAuction in
    
    let modified_auction = { currentAuction with reservePrice=param.reservePrice } in
    let modified_auctions = Big_map.update param.saleId (Some(modified_auction)) store.auctionIdToAuction in  
    (([] : operation list), { store with auctionIdToAuction=modified_auctions })

let main(ep, store : parameter * storage) : return =
    match ep with 
    | SetBidOrder p -> setBidOrder(p, store)
    | FinalizeAuction p -> finalizeAuction(p, store)
    | SetNftAuction p -> setNftAuction(p, store)
    | CancelNftAuction p -> cancelNftAuction(p, store)
    | AdminCancelNftAuction p -> adminCancelNftAuction(p, store)
    | UpdateNftAuctionPeriods p -> updateNftAuctionPeriods(p, store)
    | UpdateReservePriceNftAuction p -> updateReservePriceNftAuction(p, store)
    | SetCommissionFee p -> setCommissionFee(p, store)
    | SetReserveAddress p -> setReserveAddress(p, store)
    | SetRoyaltiesStorageAddress p -> setRoyaltiesStorageAddress(p, store)
    | EmergencyPause p -> emergencyPause(p, store)


[@view] let get_auction_item : (nat * storage) -> Storage.nftauction = 
    fun ((saleId, s) : (nat * storage)) -> 
        match Big_map.find_opt saleId s.auctionIdToAuction with
        | None -> (failwith(Errors.unknown_auction_id) : Storage.nftauction)
        | Some item -> item 