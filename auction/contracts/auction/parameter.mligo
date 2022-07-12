#import "storage.mligo" "Storage"

type sell_proposal_param = {
    token_id : nat;
    collectionContract : address;
    price : tez;
}

type buy_param = {
    proposal_id : nat
}

type saleId = nat

type set_bid_order_param = saleId
type finalize_auction_param = saleId
type set_fee_param = nat
type set_reserve_param = address
type set_royalties_param = address
type set_nft_auction_param = {
    nftAddress : address;
    tokenId : nat;
    reservePrice : nat;
    auctionBiddingPeriod : nat;
    auctionExpirationPeriod : nat;
    assetClass : Storage.auctionAssetClass;
    tokenAmount : nat;
}
type cancel_nft_auction_param = nat
type admin_cancel_nft_auction_param = {
    saleId : saleId;
    reason : string;
}
type update_periods_param = {
    saleId : saleId;
    auctionBiddingPeriod : nat;
    auctionExpirationPeriod : nat;
}
type update_price_param = {
    saleId : saleId;
    reservePrice : nat;
}
type pause_param = bool

type t = 
| SetBidOrder of set_bid_order_param
| FinalizeAuction of finalize_auction_param
| SetCommissionFee of set_fee_param
| SetReserveAddress of set_reserve_param
| SetRoyaltiesStorageAddress of set_royalties_param
| SetNftAuction of set_nft_auction_param
| CancelNftAuction of cancel_nft_auction_param
| AdminCancelNftAuction of admin_cancel_nft_auction_param
| UpdateNftAuctionPeriods of update_periods_param
| UpdateReservePriceNftAuction of update_price_param
| EmergencyPause of pause_param