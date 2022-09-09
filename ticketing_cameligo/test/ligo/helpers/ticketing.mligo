#import "../../../src/main.mligo" "Ticketing"
#import "./assert.mligo" "Assert"
#import "./nft.mligo" "NFT_helper"

(* Some types for readability *)
type taddr = (Ticketing.parameter, Ticketing.storage) typed_address
type contr = Ticketing.parameter contract
type originated = {
    addr: address;
    taddr: taddr;
    contr: contr;
}

let metadata_empty : (string, bytes) big_map = (Big_map.empty : (string, bytes) big_map)

(* Base Ticketing storage *)
let base_storage : Ticketing.storage = {
    all_tickets = (Big_map.empty : Ticketing.Storage.tickets);
    data = {
        prices = Big_map.literal[("PARKING", 10tez)];
        metadata = metadata_empty
    }
}

(* Originate a Ticketing contract with given init_storage storage *)
let originate (init_storage : Ticketing.storage) =
    let (taddr, _, _) = Test.originate Ticketing.main init_storage 0mutez in
    let contr = Test.to_contract taddr in
    let addr = Tezos.address contr in
    {addr = addr; taddr = taddr; contr = contr}

(* Call entry point of Ticketing contr contract *)
let call (p, contr : Ticketing.parameter * contr) =
    Test.transfer_to_contract contr (p) 0mutez

(* Call entry point of Ticketing contr contract with amount *)
let call_with_amount (p, amount_, contr : Ticketing.parameter * tez * contr) =
    Test.transfer_to_contract contr p amount_

let call_success (p, contr: Ticketing.parameter * contr) =
    Assert.tx_success (call(p, contr))

(* Entry points call helpers *)
let redeem_ticket (p, contr : Ticketing.Parameter.redeemTicketParam * contr) =
    call(RedeemTicket(p), contr)

let buy_ticket (p, amount_, contr : Ticketing.Parameter.buyTicketParam * tez * contr) =
    call_with_amount(BuyTicket(p), amount_, contr)

(* Asserter helper for successful entry point calls *)
let redeem_ticket_success (p, contr : Ticketing.Parameter.redeemTicketParam * contr) =
    Assert.tx_success (redeem_ticket(p, contr))

let buy_ticket_success (p, amount_, contr : Ticketing.Parameter.buyTicketParam * tez * contr) =
    Assert.tx_success (buy_ticket(p, amount_, contr))

type unforged_storage = (string unforged_ticket) option

(* assert Ticketing contract at [taddr] have [owner] address with [amount] tickets *)
let assert_owned_ticket_amount (addr, taddr, owner, ticket_type, _amount : address * taddr * Ticketing.Storage.owner * Ticketing.Storage.ticket_type * nat) =
    let storage : michelson_program = Test.get_storage_of_address addr in

    let s = Test.get_storage taddr in
    let (ticket, _ticket_map) = Big_map.get_and_update (owner, ticket_type) (None : Ticketing.Storage.ticket_value option) s.all_tickets in
    let ticket_to_decompile : michelson_program = Test.eval ticket.1 in
    let unforged_storage = (Test.decompile ticket_to_decompile : unforged_storage) in
    Test.log(unforged_storage)


    //let s = Test.get_storage taddr in
    //let unforged_storage = (Test.decompile s.all_tickets : unforged_storage) in
    //Test.log(unforged_storage)

    //let { data = _d; all_tickets = tis } = Test.get_storage taddr in 
    // retrieve ticket from ticket_map


    //let { ticketer = ticketer ; value =value ; amount = amt } = tval in
    //let (tt, (ticketer, (value, amt))) : string unforged_ticket = tval in
    // //let ((_,(_, amt)), tval) = Tezos.read_ticket tval in
