
type counter = nat

type auctionAssetClass = NFT | NFT_MULTI

type nftauction = {
    saleId : counter;
    nftAddress : address;
    tokenId : nat;
    sellerAddress: address;
    bidderAddress : address option;
    reservePrice : nat;
    auctionPrice : nat;
    biddingPeriod : nat;
    expirationTime : timestamp option;
    endTime : timestamp option;
    assetClass : auctionAssetClass;
    tokenAmount : nat;
}

type auctions = (nat, nftauction) big_map

type t = {
    admin : address;
    min_bp_bid : nat;
    commissionFee : nat;
    reserveAddress : address;
    royaltiesStorage : address;
    isPaused : bool;
    nftSaleId : counter;
    auctionIdToAuction : auctions;
    extension_duration : nat;
}