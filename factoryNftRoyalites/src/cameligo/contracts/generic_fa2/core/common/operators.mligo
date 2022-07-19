(** 
This file implement the TZIP-12 protocol (a.k.a FA2) for NFT on Tezos
copyright Wulfman Corporation 2021
*)

#import "errors.mligo" "Errors"
#import "address.mligo" "Address"

type owner    = Address.t
type operator = Address.t
type token_id = nat
type t = ((owner * operator), token_id set) big_map

(** if transfer policy is Owner_or_operator_transfer *)
let assert_authorisation (operators : t) (from_ : Address.t) (token_id : nat) : unit = 
   let sender_ = Tezos.sender in
   if (Address.equal sender_ from_) then ()
   else 
   let authorized = match Big_map.find_opt (from_,sender_) operators with
      Some (a) -> a | None -> Set.empty
   in if Set.mem token_id authorized then ()
   else failwith Errors.not_operator
(** if transfer policy is Owner_transfer
let assert_authorisation (operators : t) (from_ : Address.t) : unit = 
   let sender_ = Tezos.sender in
   if (sender_ = from_) then ()
   else failwith Errors.not_owner
*)

(** if transfer policy is No_transfer
let assert_authorisation (operators : t) (from_ : Address.t) : unit = 
   failwith Errors.no_owner
*)

let is_operator (operators, owner, operator, token_id : (t * Address.t * Address.t * nat)) : bool =
   let authorized = match Big_map.find_opt (owner,operator) operators with
      Some (a) -> a | None -> Set.empty in
   (owner = operator || Set.mem token_id authorized)

let assert_update_permission (owner : owner) : unit =
   assert_with_error (Address.equal owner Tezos.sender) Errors.only_sender_manage_operators

let add_operator (operators : t) (owner : owner) (operator : operator) (token_id : token_id) : t =
   if owner = operator then operators (* assert_authorisation always allow the owner so this case is not relevant *)
   else
      let () = assert_update_permission owner in
      let auth_tokens = match Big_map.find_opt (owner,operator) operators with
         Some (ts) -> ts | None -> Set.empty in
      let auth_tokens  = Set.add token_id auth_tokens in
      Big_map.update (owner,operator) (Some auth_tokens) operators
      
let remove_operator (operators : t) (owner : owner) (operator : operator) (token_id : token_id) : t =
   if owner = operator then operators (* assert_authorisation always allow the owner so this case is not relevant *)
   else
      let () = assert_update_permission owner in
      let auth_tokens = match Big_map.find_opt (owner,operator) operators with
      None -> None | Some (ts) ->
         let ts = Set.remove token_id ts in
         [@no_mutation] let is_empty = Set.size ts = 0n in 
         if is_empty then None else Some (ts)
      in
      Big_map.update (owner,operator) auth_tokens operators