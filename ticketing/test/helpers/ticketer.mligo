#import "../../src/ticketer.mligo" "Ticketer"
#import "./assert.mligo" "Assert"

(* Some types for readability *)
type taddr = (unit, Ticketer.storage) typed_address
type contr = unit contract
type originated = {
    addr: address;
    taddr: taddr;
    contr: contr;
}

(**
    "unforged" storage type is used to decompile the storage while being able
    to read its tickets
*)
type unforged_ticket = unit unforged_ticket
type unforged_storage = {
    data : { price : tez };
    tickets : (address, unforged_ticket) big_map
}

(* Base Ticketer storage *)
let base_storage (price: tez) : Ticketer.storage = {
    data = {
        price = price;
    };
    tickets = (Big_map.empty: (address, unit ticket) big_map);
}

(* Originate a Ticketer contract with given init_storage storage *)
let originate (init_storage : Ticketer.storage) =
    let (taddr, _, _) = Test.originate Ticketer.main init_storage 0mutez in
    let contr = Test.to_contract taddr in
    let addr = Tezos.address contr in
    {addr = addr; taddr = taddr; contr = contr}

(* Call entry point of Ticketer contr contract *)
let call (contr : contr) =
    Test.transfer_to_contract contr () 0mutez

(* Call entry point of Ticketer contr contract with amount *)
let call_with_amount (amount_, contr : tez * contr) =
    Test.transfer_to_contract contr () amount_

let call_success (contr: contr) =
    Assert.tx_success (call(contr))

(* Entry points call helpers *)
(* let redeem_ticket (p, contr : Ticketer.redeem_ticket_params * contr) = *)
(*     call(RedeemTicket(p), contr) *)

let buy_ticket (amount_, contr : tez * contr) =
    call_with_amount(amount_, contr)

(* Asserter helper for successful entry point calls *)
(* let redeem_ticket_success (p, contr : Ticketer.redeem_ticket_params * contr) = *)
(*     Assert.tx_success (redeem_ticket(p, contr)) *)

let buy_ticket_success (amount_, contr : tez * contr) =
    Assert.tx_success (buy_ticket(amount_, contr))

(* get "unforged" storage of contract at [addr] *)
let get_unforged_storage (addr: address) : unforged_storage =
    let storage : michelson_program = Test.get_storage_of_address addr in
    Test.decompile storage

(* assert that contract at [addr] has [owner] ticket for [amount_] amount *)
let assert_has_tickets (addr, owner, amount_: address * address * nat) =
    let storage = get_unforged_storage(addr) in
    match Big_map.find_opt owner storage.tickets with
        None -> Test.failwith "A ticket should have been found"
        | Some ticket -> assert (ticket.amount = amount_)
