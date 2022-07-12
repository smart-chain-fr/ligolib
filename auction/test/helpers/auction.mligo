#import "../../contracts/auction/main.mligo" "Auction"

type taddr = (Auction.parameter, Auction.storage) typed_address
type contr = Auction.parameter contract
type originated = {
    addr: address;
    taddr: taddr;
    contr: contr;
}

(* Base Auction storage *)
let base_storage(admin, min_bp_bid, commission_fee, reserve, royalties : address * nat * nat * address * address) : Auction.storage = {
    admin=admin;
    min_bp_bid=min_bp_bid;
    commissionFee=commission_fee;
    reserveAddress=reserve;
    royaltiesStorage=royalties;
    isPaused=false;
    nftSaleId=0n;
    auctionIdToAuction=(Big_map.empty : Auction.Storage.auctions);
    extension_duration=100n;
}


(* given Auction storage *)
let fill_partial_storage(store : Auction.storage) : Auction.storage = 
    store


(* Originate a Auction contract with given init_storage storage *)
let originate (init_storage, init_balance : Auction.storage * tez) =
    let (taddr, _, _) = Test.originate Auction.main init_storage init_balance in
    let contr = Test.to_contract taddr in
    let addr = Tezos.address contr in
    {addr = addr; taddr = taddr; contr = contr}

(* Call entry point of Auction contr contract *)
let call (p, contr : Auction.parameter * contr) =
    Test.transfer_to_contract contr p 0mutez

(* Call entry point of Auction contr contract with amount *)
let call_with_amount (p, amount_, contr : Auction.parameter * tez * contr) =
    Test.transfer_to_contract contr p amount_