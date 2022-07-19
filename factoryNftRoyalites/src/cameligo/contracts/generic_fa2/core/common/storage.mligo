(** 
   This file implement the TZIP-12 protocol (a.k.a FA2) for NFT on Tezos
   copyright Wulfman Corporation 2021
*)

#import "errors.mligo" "Errors"
#import "address.mligo" "Address"
#import "operators.mligo" "Operators"
#import "tokenMetadata.mligo" "TokenMetadata"
#import "ledger.mligo" "Ledger"

type token_id = nat
type 'a t = {
   ledger : Ledger.t;
   token_metadata : TokenMetadata.t;
   operators : Operators.t;
   token_ids : token_id list;
   extension : 'a;
}

let is_owner_of (type a) (s:a t) (owner : Address.t) (token_id : token_id) : bool = 
   Ledger.is_owner_of s.ledger token_id owner

let assert_token_exist (type a) (s:a t) (token_id : nat) : unit  = 
   let _ = Option.unopt_with_error (Big_map.find_opt token_id s.token_metadata)
      Errors.undefined_token in
   ()

let set_ledger (type a) (s:a t) (ledger:Ledger.t) = {s with ledger = ledger}

let get_operators (type a) (s:a t) = s.operators
let set_operators (type a) (s:a t) (operators:Operators.t) = {s with operators = operators}

let get_balance (type a) (s:a t) (owner : Address.t) (token_id : nat) : nat =
   let ()       = assert_token_exist s token_id in 
   if is_owner_of s owner token_id then 1n else 0n