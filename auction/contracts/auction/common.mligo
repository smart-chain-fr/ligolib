#import "errors.mligo" "Errors"
#import "storage.mligo" "Storage"
#import "../generic_fa2/core/instance/NFT.mligo" "NFT_FA2"
#import "../nft_multi/core/instance/NFT.mligo" "NFT_MULTI"


let no_amount() : bool = Tezos.get_amount() = 0tez
let assert_no_amount() : unit = assert_with_error (no_amount() ) Errors.expects_no_amount

let only_admin(store : Storage.t) : bool = Tezos.get_sender() = store.admin
let assert_only_admin(store : Storage.t) : unit = assert_with_error (only_admin(store)) Errors.not_admin

let is_paused(store : Storage.t) : bool = store.isPaused
let assert_is_not_paused(store : Storage.t) : unit = assert_with_error (is_paused store = false) Errors.in_pause

let is_expired(auction : Storage.nftauction) : bool = match auction.expirationTime with
| None -> false
| Some tt -> tt < Tezos.get_now()
let assert_is_not_expired(auction : Storage.nftauction) : unit = assert_with_error (is_expired auction = false) Errors.auction_expired

// let is_started(orderData : SMARTORDER.order) : bool = orderData.startTime <= Tezos.get_now()
// let assert_is_started(orderData : SMARTORDER.order) : unit = assert_with_error (is_started orderData = true) Errors.order_not_started

let is_over(auction : Storage.nftauction) : bool = match auction.endTime with 
| None -> false
| Some v -> v < Tezos.get_now()
let assert_auction_is_not_over(auction : Storage.nftauction) : unit = assert_with_error (is_over auction = false) Errors.auction_is_over


let is_started(auction : Storage.nftauction) : bool = match auction.endTime with 
| None -> false
| Some v -> true
let assert_auction_is_not_started(auction : Storage.nftauction) : unit = assert_with_error (is_started auction = false) Errors.auction_already_started
let assert_auction_is_started(auction : Storage.nftauction) : unit = assert_with_error (is_started auction = true) Errors.auction_not_started


let is_sender_last_bidder(auction : Storage.nftauction) : bool = match auction.bidderAddress with
| None -> false
| Some addr -> addr = Tezos.get_sender()
let assert_no_twice_bidding(auction : Storage.nftauction) : unit = assert_with_error (is_sender_last_bidder auction = false) Errors.cannot_bid_twice

let is_bid_enough(auction, store : Storage.nftauction * Storage.t) : bool = Tezos.get_amount() / 1mutez >= auction.auctionPrice + store.min_bp_bid
let assert_bid_is_enough(auction, store : Storage.nftauction * Storage.t) : unit = assert_with_error (is_bid_enough(auction,store)) Errors.bid_amount_too_low

let assert_reason_is_given(reason : string) : unit = assert_with_error (String.length reason > 0n) Errors.no_reason

let has_auction_reserve_price(auction : Storage.nftauction) : bool = auction.reservePrice <> 0n
let assert_auction_reserve_price_not_zero(auction : Storage.nftauction) : unit = assert_with_error (has_auction_reserve_price auction) Errors.no_reserve_price


let has_reserve_price(reservePrice : nat) : bool = reservePrice <> 0n
let assert_reserve_price_not_zero(reservePrice : nat) : unit = assert_with_error (has_reserve_price reservePrice) Errors.no_reserve_price


let has_expiration_period(exp_period : nat) : bool = exp_period <> 0n
let assert_expiration_period_not_zero(exp_period : nat) : unit = assert_with_error (has_expiration_period exp_period) Errors.no_expiration_period

let has_bidding_period(bid_period : nat) : bool = bid_period <> 0n
let assert_bidding_period_not_zero(bid_period : nat) : unit = assert_with_error (has_bidding_period bid_period) Errors.no_bidding_period


let is_auction_ended(auction : Storage.nftauction) : bool = match auction.endTime with 
| None -> false
| Some endtime -> Tezos.get_now() > endtime
let assert_auction_is_not_ended(auction : Storage.nftauction) : unit = assert_with_error (is_auction_ended auction = false) Errors.auction_not_ended


let verify_entrypoint_tranfer_nft(contractAddress : address) : bool = 
    match (Tezos.get_entrypoint_opt "%transfer" contractAddress : NFT_FA2.NFT.transfer contract option) with
    | None -> false
    | Some ctr -> true

let verify_entrypoint_tranfer_nft_multi(contractAddress : address) : bool = 
    match (Tezos.get_entrypoint_opt "%transfer" contractAddress : NFT_MULTI.NFT.transfer contract option) with
    | None -> false
    | Some ctr -> true

let assert_nft_contract_exist(contractAddress, assetClass : address * Storage.auctionAssetClass) : unit = 
     match assetClass with
    | NFT -> assert_with_error (verify_entrypoint_tranfer_nft contractAddress) Errors.nft_address_does_not_exist
    | NFT_MULTI -> assert_with_error (verify_entrypoint_tranfer_nft_multi contractAddress) Errors.nft_address_does_not_exist


let transferAsset(assetClass, nftAddress, sellerAddress, tokenId, tokenAmount : Storage.auctionAssetClass * address * address * nat * nat) : operation =
    match assetClass with
    | NFT -> 
        let dest : NFT_FA2.NFT.transfer contract = match (Tezos.get_entrypoint_opt "%transfer" nftAddress : NFT_FA2.NFT.transfer contract option) with
        | None -> (failwith("unknown NFT address") : NFT_FA2.NFT.transfer contract)
        | Some ctr -> ctr
        in
        let transfer_param : NFT_FA2.NFT.transfer = [{ from_=Tezos.get_self_address(); tx=[{ to_=sellerAddress; token_id=tokenId}] }] in
        let op : operation = Tezos.transaction transfer_param 0mutez dest in
        op
    | NFT_MULTI ->
        let dest : NFT_MULTI.NFT.transfer contract = match (Tezos.get_entrypoint_opt "%transfer" nftAddress : NFT_MULTI.NFT.transfer contract option) with
        | None -> failwith("unknown NFT address")
        | Some ctr -> ctr
        in
        let transfer_param : NFT_MULTI.NFT.transfer = [{ from_=Tezos.get_self_address(); tx=[{ to_=sellerAddress; token_id=tokenId; amount=tokenAmount}] }] in
        let op : operation = Tezos.transaction transfer_param 0mutez dest in
        op

let transferAssetToAuctionContract(assetClass, nftAddress, tokenId, from_address, to_address, tokenAmount : Storage.auctionAssetClass * address * nat * address * address * nat) : operation =
    match assetClass with
    | NFT -> 
        let dest : NFT_FA2.NFT.transfer contract = match (Tezos.get_entrypoint_opt "%transfer" nftAddress : NFT_FA2.NFT.transfer contract option) with
        | None -> (failwith("unknown NFT address") : NFT_FA2.NFT.transfer contract)
        | Some ctr -> ctr
        in
        let transfer_param : NFT_FA2.NFT.transfer = [{ from_=from_address; tx=[{ to_=to_address; token_id=tokenId}] }] in
        let op : operation = Tezos.transaction transfer_param 0mutez dest in
        op
    | NFT_MULTI ->
        let dest : NFT_MULTI.NFT.transfer contract = match (Tezos.get_entrypoint_opt "%transfer" nftAddress : NFT_MULTI.NFT.transfer contract option) with
        | None -> failwith("unknown NFT address")
        | Some ctr -> ctr
        in
        let transfer_param : NFT_MULTI.NFT.transfer = [{ from_=from_address; tx=[{ to_=to_address; token_id=tokenId; amount=1n}] }] in
        let op : operation = Tezos.transaction transfer_param 0mutez dest in
        op