#import "generic_fa2/core/instance/NFT.mligo" "NFT_FA2"

type buyTicketParam = [@layout:comb] {
    ticket_amount : nat;
    ticket_owner : address;
    ticket_type : string; 
}

type redeemTicketParam = [@layout:comb] {
    ticket_type : string;
    ticket_amount : nat;
}

type t = BuyTicket of buyTicketParam | RedeemTicket of redeemTicketParam