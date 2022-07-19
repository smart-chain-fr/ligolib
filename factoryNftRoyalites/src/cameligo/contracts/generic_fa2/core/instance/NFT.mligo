
#import "../common/errors.mligo" "Errors"
#import "../common/address.mligo" "Address"
#import "../common/storage.mligo" "Storage"
#import "../common/ledger.mligo" "Ledger"
#import "../common/tokenMetadata.mligo" "TokenMetadata"
#import "../common/NFT.mligo" "NFT"

(*
   Specialization corner
*)

type extension = {
   admin : Address.t;
   royalties : tez;
}

type storage = Storage.t

let authorize_extension (s:extension storage): unit =
   assert_with_error (Tezos.sender = s.extension.admin) Errors.only_admin

let transfer_extension (t: NFT.transfer) (s:extension storage): operation list * extension storage =
   
   let process_atomic_royalties (oplist, t:operation list * NFT.atomic_trans) = 
      // get author from metadata
      let info : NFT.TokenMetadata.data = NFT.TokenMetadata.get_token_metadata t.token_id s.token_metadata in
      let _check_info_token_id : unit = assert(info.token_id = t.token_id) in
      let author_opt : address option = match Map.find_opt "author" info.token_info with
      | None -> (failwith("missing author in token_metadata") : address option) //(None : address option)
      | Some addr_bytes -> Bytes.unpack addr_bytes
      in  
      match author_opt with
      | None -> oplist
      | Some author -> 
         // produce a transaction Tezos.transaction unit s.royalties author
         let destination_opt : unit contract option = Tezos.get_contract_opt author in
         let destination : unit contract = match destination_opt with 
         | None -> (failwith("author account not found") : unit contract)
         | Some dest -> dest
         in
         let op : operation = Tezos.transaction unit s.extension.royalties destination in
         op :: oplist
   in
   let process_royalties_single_transfer (ops, t:operation list * NFT.transfer_from ) = List.fold process_atomic_royalties t.tx ops in
   let ops_royalties = List.fold process_royalties_single_transfer t ([]: operation list) in
   // check that (Tezos.amount == expected royalties) ... not needed 
   //let count (acc, _i: nat * operation) : nat = acc + 1n in
   //let nb_of_elements : nat = List.fold count ops_royalties 0n in
   //let _check_amount : unit = assert_with_error (Tezos.amount >= nb_of_elements * s.extension.royalties) "missing tez for royalties" in
   ops_royalties,s


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