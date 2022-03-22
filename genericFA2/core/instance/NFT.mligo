#import "../common/errors.mligo" "Errors"
#import "../common/address.mligo" "Address"
#import "../common/storage.mligo" "Storage"
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


type parameter = [@layout:comb] 
| Transfer of NFT.transfer
| Balance_of of NFT.balance_of 
| Update_operators of NFT.update_operators 
| Mint of NFT.mint_param

let main ((p,s):(parameter * extension storage)) : operation list * extension storage = 
match p with
   Transfer         p -> let o1, s = NFT.transfer p s in
                         let o2, s = transfer_extension p s in
                         let o = List.fold_left (fun ((a,x):operation list * operation) -> x :: a) o2 o1 in
                         o, s
|  Balance_of       p -> NFT.balance_of p s
|  Update_operators p -> NFT.update_ops p s
|  Mint             p -> let _ = authorize_extension s in 
                         NFT.mint p s

[@view] let token_usage ((p, s) : (nat * extension storage)): nat =
      TokenUsage.get_token_usage p s.extension.token_usage
