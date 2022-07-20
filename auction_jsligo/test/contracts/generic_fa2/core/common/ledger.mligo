(** 
   This file implement the TZIP-12 protocol (a.k.a FA2) for NFT on Tezos
   copyright Wulfman Corporation 2021
*)

#import "errors.mligo" "Errors"
#import "address.mligo" "Address"

type token_id = nat
type owner = Address.t
type t = (token_id,owner) big_map

let is_owner_of (ledger:t) (token_id : token_id) (owner: Address.t) : bool =
   (** We already sanitized token_id, a failwith here indicated a patological storage *)
   let current_owner = Option.unopt (Big_map.find_opt token_id ledger) in
   Address.equal current_owner owner

let assert_owner_of (ledger:t) (token_id : token_id) (owner: Address.t) : unit =
   assert_with_error (is_owner_of ledger token_id owner) Errors.ins_balance

let transfer_token_from_user_to_user (ledger : t) (token_id : token_id) (from_ : owner) (to_ : owner) : t = 
   let () = assert_owner_of ledger token_id from_ in
   let ledger = Big_map.update token_id (Some to_) ledger in
   ledger 