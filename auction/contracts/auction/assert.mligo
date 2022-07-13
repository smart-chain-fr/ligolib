#import "errors.mligo" "Errors"
#import "common.mligo" "Common"
#import "storage.mligo" "Storage"

let assert_no_amount() : unit = assert_with_error (Common.no_amount() ) Errors.expects_no_amount
let assert_only_admin(store : Storage.t) : unit = assert_with_error (Common.only_admin(store)) Errors.not_admin

let assert_is_not_paused(store : Storage.t) : unit = assert_with_error (Common.is_paused store = false) Errors.in_pause
let assert_is_not_expired(auction : Storage.nftauction) : unit = assert_with_error (Common.is_expired auction = false) Errors.auction_expired

let assert_auction_is_not_over(auction : Storage.nftauction) : unit = assert_with_error (Common.is_over auction = false) Errors.auction_is_over
let assert_auction_is_not_started(auction : Storage.nftauction) : unit = assert_with_error (Common.is_started auction = false) Errors.auction_already_started
let assert_auction_is_started(auction : Storage.nftauction) : unit = assert_with_error (Common.is_started auction = true) Errors.auction_not_started

let assert_no_twice_bidding(auction : Storage.nftauction) : unit = assert_with_error (Common.is_sender_last_bidder auction = false) Errors.cannot_bid_twice

let assert_bid_is_enough(auction, store : Storage.nftauction * Storage.t) : unit = assert_with_error (Common.is_bid_enough(auction,store)) Errors.bid_amount_too_low

let assert_reason_is_given(reason : string) : unit = assert_with_error (String.length reason > 0n) Errors.no_reason

let assert_auction_reserve_price_not_zero(auction : Storage.nftauction) : unit = assert_with_error (Common.has_auction_reserve_price auction) Errors.no_reserve_price
let assert_reserve_price_not_zero(reservePrice : nat) : unit = assert_with_error (Common.has_reserve_price reservePrice) Errors.no_reserve_price

let assert_expiration_period_not_zero(exp_period : nat) : unit = assert_with_error (Common.has_expiration_period exp_period) Errors.no_expiration_period
let assert_bidding_period_not_zero(bid_period : nat) : unit = assert_with_error (Common.has_bidding_period bid_period) Errors.no_bidding_period
let assert_auction_is_not_ended(auction : Storage.nftauction) : unit = assert_with_error (Common.is_auction_ended auction = false) Errors.auction_not_ended

let assert_nft_contract_exist(contractAddress, assetClass : address * Storage.auctionAssetClass) : unit = 
     match assetClass with
    | NFT -> assert_with_error (Common.verify_entrypoint_tranfer_nft contractAddress) Errors.nft_address_does_not_exist
    | NFT_MULTI -> assert_with_error (Common.verify_entrypoint_tranfer_nft_multi contractAddress) Errors.nft_address_does_not_exist
