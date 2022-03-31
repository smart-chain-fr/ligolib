#import "tezos-ligo-fa2/lib/fa2/asset/single_asset.mligo" "FA2"
#import "./errors.mligo" "Errors"

type t = address

(** 
    [get_transfer_entrypoint(addr)] gets the entrypoint %transfer of the contract at address [addr].
    Raises [Errors.receiver_not_found] is the contract or entrypoint is not found.
*)
let get_transfer_entrypoint (addr : address) : FA2.transfer contract =
    match (Tezos.get_entrypoint_opt "%transfer" addr : FA2.transfer contract option) with
        None -> failwith Errors.receiver_not_found
        | Some c -> c

(**
    [transfer(token_addr, from_, to_, amount_) creates an operation for a transfer of tokens 
    of contract residing at [token_addr] address between [from_] and [to_] addresses with [amount_] tokens.
*)
let transfer (token_addr, from_, to_, amount_: t * address * address * nat) : operation =
    let dest = get_transfer_entrypoint (token_addr) in
    let transfer_requests = ([
      ({from_=from_; tx=([{to_=to_;amount=amount_}] : FA2.atomic_trans list)});
    ] : FA2.transfer) in
    let op = Tezos.transaction transfer_requests 0mutez dest in
    op

(**
    [get_total_supply(token_addr) calls the [token_addr] view to find out the total supply of tokens]
*)
let get_total_supply (token_addr : t) : nat option = Tezos.call_view "total_supply" unit token_addr
