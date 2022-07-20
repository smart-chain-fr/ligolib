
#import "../common/errors.mligo" "Errors"
#import "../common/address.mligo" "Address"
#import "../common/storage.mligo" "Storage"
#import "../common/ledger.mligo" "Ledger"
#import "../common/tokenMetadata.mligo" "TokenMetadata"
#import "../common/NFT.mligo" "NFT"

#import "errors.mligo" "ErrorsExtension"
(*
   Specialization corner
*)

module TotalSupply = struct 
   type token_id = nat
   type amount_ = nat
   type t = (token_id, amount_) big_map

   let get_for_token_id (totalsupplies:t) (token_id : token_id) : amount_ =
      match Big_map.find_opt token_id totalsupplies with Some (a) -> a | None -> 0n

   let set_for_token_id (totalsupplies:t) (token_id : token_id) (amount_:amount_) : t = 
      Big_map.update token_id (Some amount_) totalsupplies

   let increase_token_amount_for_token_id (totalsupplies : t) (token_id : nat) (amount_ : nat) : t = 
      let totalsupply_ = get_for_token_id totalsupplies token_id in
      let totalsupply_ = totalsupply_ + amount_ in
      let totalsupplies = set_for_token_id totalsupplies token_id totalsupply_ in
      totalsupplies 

end 

type extension = {
   admin : Address.t;
   artist : Address.t;
   allocations : (address, nat) map;
   allocations_decimals : nat;
   total_supply : TotalSupply.t;
   initial_prices : (nat, tez) big_map;
   metadata: (string, bytes) big_map;
}

type storage = Storage.t

let authorize_admin (s:extension storage): unit =
   assert_with_error (Tezos.get_sender() = s.extension.admin) Errors.only_admin

let authorize_admin_and_artist (s:extension storage): unit =
   assert_with_error ((Tezos.get_sender() = s.extension.admin) or (Tezos.get_sender() = s.extension.artist)) ErrorsExtension.only_admin_or_artist


let transfer_extension (_t: NFT.transfer) (s:extension storage): operation list * extension storage =
   // let process_atomic_usage (usage, t:TokenUsage.t * NFT.atomic_trans) = TokenUsage.update_usage_token usage t.token_id in
   // let update_usage_single_transfer (usage, t:TokenUsage.t * NFT.transfer_from ) = List.fold process_atomic_usage t.tx usage in
   // let usage = List.fold update_usage_single_transfer t s.extension.token_usage in
   // let s = set_usage s usage in
   ([]: operation list),s

type premint_param = [@layout:comb] {
   ids : Storage.token_id list;
   quantity : (Storage.token_id, nat) big_map;
   metas : (Storage.token_id, (string, bytes) map) big_map;
   initial_prices : (nat, tez) big_map
}

let premint (param: premint_param) (s: extension storage) : operation list * extension storage =
 
   // update token_ids
   let add_id(acc, id : nat list * nat) : nat list = 
      match Big_map.find_opt id s.token_metadata with
      | None -> id :: acc
      | Some _x -> acc
   in
   let new_token_ids : nat list = List.fold add_id param.ids s.token_ids in

   // update ledger
   let set_token_owner (acc, elt : (Ledger.t * TotalSupply.t) * Storage.token_id) : (Ledger.t * TotalSupply.t) = 
      let param_amount : nat = match (Big_map.find_opt elt param.quantity : nat option) with 
      | None -> (failwith(ErrorsExtension.missing_quantity) : nat)
      | Some val -> val
      in
      (Ledger.increase_token_amount_for_user acc.0 s.extension.artist elt param_amount,
      TotalSupply.increase_token_amount_for_token_id acc.1 elt param_amount)
   in
   let (new_ledger,new_totalsupply) : (Ledger.t * TotalSupply.t) = List.fold set_token_owner param.ids (s.ledger, s.extension.total_supply) in

   // update token_metadata
   let add_token (acc, elt : (TokenMetadata.t * (Storage.token_id, (string, bytes) map) big_map) * Storage.token_id) : (TokenMetadata.t * (Storage.token_id, (string, bytes) map) big_map) =
      let current_token_info, update : (string, bytes) map * bool = match Big_map.find_opt elt acc.1 with
      | None -> (match Big_map.find_opt elt acc.0 with
         | None -> (failwith(ErrorsExtension.missing_token_info) :(string, bytes) map * bool)
         | Some ex_md -> (ex_md.token_info, false))
      | Some ti -> (ti, true)
      in
      if update then
         let current_metadata : TokenMetadata.data = { token_id=elt; token_info=current_token_info } in
         match Big_map.find_opt elt acc.0 with
         | None -> (Big_map.add elt current_metadata acc.0, acc.1)
         | Some _x -> (failwith(ErrorsExtension.already_preminted) : (TokenMetadata.t * (Storage.token_id, (string, bytes) map) big_map))
      else
         (acc.0, acc.1)
   in
   let new_token_metadata, _ = List.fold add_token param.ids (s.token_metadata, param.metas) in

   // update initial price
   let add_initial_price(acc, id: (nat, tez) big_map * Storage.token_id) : (nat, tez) big_map =
      match Big_map.find_opt id param.initial_prices with
         | None ->
            (match Big_map.find_opt id acc with
            | Some _x -> acc
            | None -> (failwith(ErrorsExtension.missing_initial_price) : (nat, tez) big_map) 
            )
         | Some param_price -> 
            (match Big_map.find_opt id acc with
            | Some _x -> (failwith(ErrorsExtension.already_price_set) : (nat, tez) big_map)
            | None -> Big_map.update id (Some(param_price)) acc
            )
   in
   let new_initial_prices = List.fold add_initial_price param.ids s.extension.initial_prices in
   let s_ext = { s.extension with total_supply=new_totalsupply; initial_prices=new_initial_prices} in
   ([]: operation list), { s with token_ids=new_token_ids; ledger=new_ledger; token_metadata=new_token_metadata; extension=s_ext }

type mint_param = [@layout:comb] {
   ids : Storage.token_id list;
   quantity : (Storage.token_id, nat) big_map;
   //metas : (Storage.token_id, (string, bytes) map) big_map
}

let mint (param: mint_param) (s: extension storage) : operation list * extension storage =
   // get total expected amount from initial price and quantity
   let get_price(acc, id : tez * nat) : tez = 
      match Big_map.find_opt id s.extension.initial_prices with
      | None -> (failwith(ErrorsExtension.missing_initial_price) : tez) 
      | Some price -> 
            let requested_amount : nat = match (Big_map.find_opt id param.quantity : nat option) with 
            | None -> (failwith(ErrorsExtension.missing_quantity) : nat)
            | Some val -> val
            in
            acc + requested_amount * price
   in
   let expected_amount : tez = List.fold get_price param.ids 0tez in
   let _check_amount : unit = assert_with_error(Tezos.get_amount() = expected_amount) ErrorsExtension.mint_ins_amount in
   
   // update ledger
   let set_token_owner (acc, elt : Ledger.t * Storage.token_id) : Ledger.t = 
      let total_amount : nat = match (Big_map.find_opt elt param.quantity : nat option) with 
      | None -> (failwith("quantity has not been defined for this token id") : nat)
      | Some val -> val
      in
      let acc : Ledger.t = Ledger.decrease_token_amount_for_user acc s.extension.artist elt total_amount in
      Ledger.increase_token_amount_for_user acc (Tezos.get_sender()) elt total_amount
   in
   let new_ledger : Ledger.t = List.fold set_token_owner param.ids s.ledger in
   let power (x, y : nat * nat) : nat = 
      let rec multiply(acc, elt, last: nat * nat * nat ) : nat = if last = 0n then acc else multiply(acc * elt, elt, abs(last - 1n)) in
      multiply(1n, x, y)
   in
   // redistribute to artist
   let compute_distribution(acc, elt : operation list * (address * nat)) : operation list =
      let dest_address : address = elt.0 in 
      let dest_amount : tez = (elt.1 * expected_amount / power(10n, s.extension.allocations_decimals)) in
      let destination_opt : unit contract option = Tezos.get_contract_opt(dest_address) in
      let destination : unit contract = match destination_opt with
      | None -> (failwith("unknown address") : unit contract)
      | Some dest -> dest
      in
      (Tezos.transaction unit dest_amount destination) :: acc
   in
   let ops : operation list = Map.fold compute_distribution s.extension.allocations ([] : operation list) in
   ops, { s with ledger=new_ledger }


type airdrop_param = [@layout:comb] {
   ids : Storage.token_id list;
   quantity : (Storage.token_id, nat) big_map;
   to : address
}

let airdrop (param: airdrop_param) (s: extension storage) : operation list * extension storage =
   let _check_amount : unit = assert_with_error(Tezos.get_amount() = 0tez) ErrorsExtension.expects_0_tez in
   // update ledger
   let set_token_owner (acc, elt : Ledger.t * Storage.token_id) : Ledger.t =
      let transfer_amount : nat = match (Big_map.find_opt elt param.quantity : nat option) with 
      | None -> (failwith("quantity has not been defined for this token id") : nat)
      | Some val -> val
      in
      let acc = Ledger.decrease_token_amount_for_user acc s.extension.artist elt transfer_amount in
      let acc = Ledger.increase_token_amount_for_user acc param.to elt transfer_amount in
      acc
   in
   let new_ledger : Ledger.t = List.fold set_token_owner param.ids s.ledger in   
   ([]: operation list), { s with ledger=new_ledger; }

type parameter = [@layout:comb] 
| Transfer of NFT.transfer
| Balance_of of NFT.balance_of 
| Update_operators of NFT.update_operators 
| Mint of mint_param
| Airdrop of airdrop_param
| Premint of premint_param

[@inline]
let main ((p,s):(parameter * extension storage)) : operation list * extension storage = 
match p with
   Transfer         p -> let o1, s = NFT.transfer p s in
                         let o2, s = transfer_extension p s in
                         let o = List.fold_left (fun ((a,x):operation list * operation) -> x :: a) o2 o1 in
                         o, s
|  Balance_of       p -> NFT.balance_of p s
|  Update_operators p -> NFT.update_ops p s
|  Mint             p -> mint p s
|  Airdrop          p -> let _ = authorize_admin s in
                         airdrop p s
|  Premint          p -> let _ = authorize_admin_and_artist s in
                         premint p s

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