
#import "../common/errors.mligo" "Errors"
#import "../common/address.mligo" "Address"
#import "../common/storage.mligo" "Storage"
#import "../common/ledger.mligo" "Ledger"
#import "../common/tokenMetadata.mligo" "TokenMetadata"
#import "../common/NFT.mligo" "NFT"

(*
   Specialization corner
*)

module TokenUsage = struct 
   type token_id = nat
   type t = (token_id, nat) big_map

   let update_usage_token (usage : t) (token_id : token_id) : t = 
      match Big_map.find_opt token_id usage with
      | None -> (failwith("This token is not initialized in usage map") : t)
      | Some old -> Big_map.update token_id (Some (old + 1n)) usage 

   let get_token_usage (token_id : nat) (tu : t) =
      match Big_map.find_opt token_id tu with
         Some data -> data
      | None -> failwith Errors.undefined_token
end

type extension = {
   admin : Address.t;
   token_usage : TokenUsage.t;
}

type storage = Storage.t

let set_usage (s:extension storage) (usage:TokenUsage.t) =
   let e = s.extension in
   let e = { e with token_usage = usage } in
   {s with extension =e }

let get_usage_of (s:extension storage) (token_id : Storage.token_id) : nat =
   match (Big_map.find_opt token_id s.extension.token_usage) with
   | None -> (failwith(Errors.undefined_token) : nat)
   | Some nb_trsfr -> nb_trsfr

let authorize_extension (s:extension storage): unit =
   assert_with_error (Tezos.sender = s.extension.admin) Errors.only_admin

let transfer_extension (t: NFT.transfer) (s:extension storage): operation list * extension storage =
   let process_atomic_usage (usage, t:TokenUsage.t * NFT.atomic_trans) = TokenUsage.update_usage_token usage t.token_id in
   let update_usage_single_transfer (usage, t:TokenUsage.t * NFT.transfer_from ) = List.fold process_atomic_usage t.tx usage in
   let usage = List.fold update_usage_single_transfer t s.extension.token_usage in
   let s = set_usage s usage in
   ([]: operation list),s


type mint_param = [@layout:comb] {
   ids : Storage.token_id list;
   metas : (Storage.token_id, (string, bytes) map) big_map
}

let mint (param: mint_param) (s: extension storage) : operation list * extension storage =
   // update token_ids
   let add_id(acc, id : nat list * nat) : nat list = id :: acc in
   let new_token_ids : nat list = List.fold add_id param.ids s.token_ids in
   
   // update ledger
   let set_token_owner (acc, elt : Ledger.t * Storage.token_id) : Ledger.t = Big_map.add elt Tezos.sender acc in
   let new_ledger : Ledger.t = List.fold set_token_owner param.ids s.ledger in
   
   // update token_metadata
   let add_token (acc, elt : (TokenMetadata.t * (Storage.token_id, (string, bytes) map) big_map) * Storage.token_id) : (TokenMetadata.t * (Storage.token_id, (string, bytes) map) big_map) =
      let current_token_info : (string, bytes) map = match Big_map.find_opt elt acc.1 with
      | None -> (failwith("Missing token_info") :(string, bytes) map)
      | Some ti -> ti
      in
      let current_metadata : TokenMetadata.data = { token_id=elt; token_info=current_token_info } in
      (Big_map.add elt current_metadata acc.0, acc.1)
   in
   let new_token_metadata, _ = List.fold add_token param.ids (s.token_metadata, param.metas) in
   ([]: operation list), { s with token_ids=new_token_ids; ledger=new_ledger; token_metadata=new_token_metadata }



type parameter = [@layout:comb] 
| Transfer of NFT.transfer
| Balance_of of NFT.balance_of 
| Update_operators of NFT.update_operators 
| Mint of mint_param

[@inline]
let main ((p,s):(parameter * extension storage)) : operation list * extension storage = 
match p with
   Transfer         p -> let o1, s = NFT.transfer p s in
                         let o2, s = transfer_extension p s in
                         let o = List.fold_left (fun ((a,x):operation list * operation) -> x :: a) o2 o1 in
                         o, s
|  Balance_of       p -> NFT.balance_of p s
|  Update_operators p -> NFT.update_ops p s
|  Mint             p -> let _ = authorize_extension s in 
                         mint p s

[@view] let token_usage ((p, s) : (nat * extension storage)): nat =
      TokenUsage.get_token_usage p s.extension.token_usage

[@view] let get_balance (p, s : (Address.t * nat) * extension storage) : nat = 
      let (owner, token_id) = p in
      let balance_ = NFT.Storage.get_balance s owner token_id in
      balance_

[@view] let total_supply ((token_id, s) : (nat * extension storage)):  nat =
      let () = NFT.Storage.assert_token_exist s token_id in
      1n

[@view] let all_tokens ((_, s) : (unit * extension storage)): nat list =
   s.token_ids
   
[@view] let is_operator ((op, s) : (NFT.operator * extension storage)): bool =
      NFT.Operators.is_operator (s.operators, op.owner, op.operator, op.token_id)

[@view] let token_metadata ((p, s) : (nat * extension storage)): NFT.TokenMetadata.data = 
      NFT.TokenMetadata.get_token_metadata p s.token_metadata