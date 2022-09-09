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
   type distribution = {
      total : nat;
      available: nat;
      reserved : nat;
   }
   type t = (token_id, distribution) big_map

   let get_distribution_for_token_id (totalsupplies:t) (token_id : token_id) : distribution =
      match Big_map.find_opt token_id totalsupplies with
      | Some (a) -> a
      | None -> (failwith(ErrorsExtension.missing_distribution) : distribution)

   let set_distribution_for_token_id (totalsupplies:t) (token_id : token_id) (distrib: distribution) : t =
      Big_map.update token_id (Some distrib) totalsupplies

   let set_total_for_token_id (totalsupplies:t) (token_id : token_id) (new_total: nat) : t =
      match Big_map.find_opt token_id totalsupplies with
      | Some distrib -> Big_map.update token_id (Some { distrib with total=new_total}) totalsupplies
      | None -> (failwith(ErrorsExtension.missing_distribution) : t)

   let set_available_for_token_id (totalsupplies:t) (token_id : token_id) (new_available: nat) : t =
      match Big_map.find_opt token_id totalsupplies with
      | Some distrib -> Big_map.update token_id (Some { distrib with available=new_available}) totalsupplies
      | None -> (failwith(ErrorsExtension.missing_distribution) : t)

   let set_reserved_for_token_id (totalsupplies:t) (token_id : token_id) (new_reserve: nat) : t =
      match Big_map.find_opt token_id totalsupplies with
      | Some distrib -> Big_map.update token_id (Some { distrib with reserved=new_reserve}) totalsupplies
      | None -> (failwith(ErrorsExtension.missing_distribution) : t)

   let increase_total_for_token_id (totalsupplies:t) (token_id : token_id) (extra_total: nat) : t =
      let distrib = get_distribution_for_token_id totalsupplies token_id in
      let new_distrib = { distrib with total=distrib.total + extra_total } in
      set_distribution_for_token_id totalsupplies token_id new_distrib

   let decrease_available_for_token_id (totalsupplies:t) (token_id : token_id) (amount_minted: nat) : t =
      let distrib = get_distribution_for_token_id totalsupplies token_id in
      let _check_limit_reached : unit = assert_with_error (distrib.available >= amount_minted) ErrorsExtension.insuffisant_available_editions in
      let new_distrib = { distrib with available=abs(distrib.available - amount_minted) } in
      set_distribution_for_token_id totalsupplies token_id new_distrib

   let decrease_reserved_for_token_id (totalsupplies:t) (token_id : token_id) (amount_minted: nat) : t =
      let distrib = get_distribution_for_token_id totalsupplies token_id in
      let _check_limit_reached : unit = assert_with_error (distrib.reserved >= amount_minted) ErrorsExtension.insuffisant_reserved_editions in
      let new_distrib = { distrib with reserved=abs(distrib.reserved - amount_minted) } in
      set_distribution_for_token_id totalsupplies token_id new_distrib
end

type currency = XTZ | EURL | USDT | ETH | EUR
//type license = NO_LICENSE | CCO | CCBY | CCBYSA
type sale = FCFS | DUTCH_AUCTION | ENGLISH_AUCTION | OFFERS | RAFFLE
//type uuid = bytes

type asset_info = {
    initial_price : tez;
    is_mintable : bool;
    max_per_wallet : nat;
    currency : currency;
    salemode : sale;
    allocations : (address, nat) map;
    allocations_decimals : nat;
    uuid : string option;
}

type extension = {
   admin : Address.t;
   creator : Address.t;
   minteed : Address.t;
   minteed_ratio : nat;
   total_supply : TotalSupply.t;
   metadata: (string, bytes) big_map;
   next_token_id : nat;
   minted_per_wallet : (address, (nat, nat)map) big_map;
   asset_infos :  (nat, asset_info) big_map;
}

type storage = Storage.t

let authorize_admin (s:extension storage): unit =
   let sender_ = Tezos.get_sender() in
   assert_with_error (sender_ = s.extension.admin) Errors.only_admin

let authorize_admin_and_creator (s:extension storage): unit =
   let sender_ = Tezos.get_sender() in
   assert_with_error ((sender_ = s.extension.admin) or (sender_ = s.extension.creator)) ErrorsExtension.only_admin_or_creator

let authorize_minteed (s:extension storage): unit =
   let sender_ = Tezos.get_sender() in
   assert_with_error (sender_ = s.extension.minteed) ErrorsExtension.only_minteed



let transfer_extension (_t: NFT.transfer) (s:extension storage): operation list * extension storage =
   // let process_atomic_usage (usage, t:TokenUsage.t * NFT.atomic_trans) = TokenUsage.update_usage_token usage t.token_id in
   // let update_usage_single_transfer (usage, t:TokenUsage.t * NFT.transfer_from ) = List.fold process_atomic_usage t.tx usage in
   // let usage = List.fold update_usage_single_transfer t s.extension.token_usage in
   // let s = set_usage s usage in
   ([]: operation list),s

type premint_asset_info = {
   quantity : nat;
   quantity_reserved : nat;
   initial_price : tez;
   is_mintable : bool;
   max_per_wallet : nat;
   currency : currency;
   salemode : sale;
   allocations : (address, nat) map;
   allocations_decimals : nat;
   uuid : string option;
   metas : (string, bytes) map;
}

type premint_param = premint_asset_info list

type tokenmetadata_param = [@layout:comb] {
   tokenid : nat;
   ipfsuri : bytes
}

let premint (param: premint_param) (s: extension storage) : operation list * extension storage =

   let create_asset(acc, elt: (nat list * TokenMetadata.t * extension) * premint_asset_info) : (nat list * TokenMetadata.t * extension) =
      let current_token_id = acc.2.next_token_id in
      // TODO : to be reviewed for production launch
      let _check_currency : unit = assert_with_error(elt.currency = XTZ) ErrorsExtension.unsupported_currency in
      let _check_salemode : unit = assert_with_error(elt.salemode = FCFS) ErrorsExtension.unsupported_sale_mode in
      (
         current_token_id :: acc.0,
         Big_map.update current_token_id (Some { token_id=current_token_id; token_info=elt.metas } ) acc.1,
         { acc.2 with
            total_supply = TotalSupply.set_distribution_for_token_id acc.2.total_supply current_token_id { total=elt.quantity; available=abs(elt.quantity - elt.quantity_reserved); reserved=elt.quantity_reserved };
            next_token_id = current_token_id + 1n;
            asset_infos = Big_map.update current_token_id (Some {
               initial_price=elt.initial_price;
               is_mintable=elt.is_mintable;
               max_per_wallet=elt.max_per_wallet;
               currency=elt.currency;
               salemode=elt.salemode;
               allocations=elt.allocations;
               allocations_decimals=elt.allocations_decimals;
               uuid=elt.uuid }) acc.2.asset_infos;
         }
      )
   in
   let (new_token_ids, new_token_metadata, new_extension) : (nat list * TokenMetadata.t * extension) =
      List.fold create_asset param (s.token_ids, s.token_metadata, s.extension) in
   (([]: operation list), { s with token_ids=new_token_ids; token_metadata=new_token_metadata; extension=new_extension })

type mint_param = [@layout:comb] {
   ids : Storage.token_id list;
   quantity : (Storage.token_id, nat) map;
}

let mint (param: mint_param) (s: extension storage) : operation list * extension storage =
   // The mint implementation supports only payments in XTZ
   let verify_currency_is_xtz(acc, tok: bool * Storage.token_id) : bool =
      match Big_map.find_opt tok s.extension.asset_infos with
      | None -> failwith ErrorsExtension.missing_currency
      | Some info -> (info.currency = XTZ) && acc
   in
   // TODO : to be reviewed for production launch
   let verify_currencies : bool = List.fold verify_currency_is_xtz param.ids true in
   // TODO : to be reviewed for production launch
   let _check_currencies : unit = assert_with_error(verify_currencies = true) ErrorsExtension.unsupported_currency in

   // verify token are mintable
   [@inline] let verify_is_mintable(acc, tok: bool * Storage.token_id) =
      match Big_map.find_opt tok s.extension.asset_infos with
      | None -> failwith ErrorsExtension.missing_mintable_token_id
      | Some info -> info.is_mintable && acc
   in
   let verify_mintable : bool = List.fold verify_is_mintable param.ids true in
   let _check_mintable : unit = assert_with_error(verify_mintable = true) ErrorsExtension.token_not_mintable in

   // get total expected amount from initial price and quantity
   let get_price(acc, id : ((nat,tez)map * tez) * nat) : (nat,tez)map * tez =
      match Big_map.find_opt id s.extension.asset_infos with
      | None -> (failwith(ErrorsExtension.missing_asset_info) : (nat,tez)map * tez)
      | Some info ->
            let requested_amount : nat = match (Map.find_opt id param.quantity : nat option) with
            | None -> (failwith(ErrorsExtension.missing_quantity) : nat)
            | Some val -> val
            in
            let amount_by_id = requested_amount * info.initial_price in
            (
               Map.add id amount_by_id acc.0,
               acc.1 + amount_by_id
            )
   in
   let (amounts_by_id, expected_total_amount) : (nat,tez)map * tez = List.fold get_price param.ids ((Map.empty : (nat,tez)map), 0tez) in
   let amount_ = Tezos.get_amount() in
   let _check_amount : unit = assert_with_error(amount_ = expected_total_amount) ErrorsExtension.mint_ins_amount in

   // update ledger
   let set_token_owner (acc, elt : (Ledger.t * TotalSupply.t) * Storage.token_id) : (Ledger.t * TotalSupply.t) =
      let total_amount : nat = match (Map.find_opt elt param.quantity : nat option) with
      | None -> (failwith("quantity has not been defined for this token id") : nat)
      | Some val -> val
      in
      let sender_ = Tezos.get_sender() in
      (
         Ledger.increase_token_amount_for_user acc.0 sender_ elt total_amount,
         TotalSupply.decrease_available_for_token_id acc.1 elt total_amount
      )
   in
   let (new_ledger, new_total_supply) : (Ledger.t * TotalSupply.t) = List.fold set_token_owner param.ids (s.ledger, s.extension.total_supply) in

   // update minted_per_wallet map
   let update_minted_per_wallet (acc, elt : (address, (nat, nat)map) big_map * Storage.token_id) : (address, (nat, nat)map) big_map =
      let max : nat = match (Big_map.find_opt elt s.extension.asset_infos : asset_info option) with
      | None -> (failwith("max per wallet has not been defined for this token id") : nat)
      | Some info -> info.max_per_wallet
      in
      let minted_amount : nat = match (Map.find_opt elt param.quantity : nat option) with
      | None -> (failwith("quantity has not been defined for this token id") : nat)
      | Some val -> val
      in
      let _check_max_minted : unit = assert_with_error (minted_amount <= max) ErrorsExtension.max_minted_reached in
      let sender_ = Tezos.get_sender() in
      let new_inner_map : (nat, nat)map = match (Big_map.find_opt sender_ acc : (nat, nat)map option) with
      | None -> Map.add elt minted_amount (Map.empty : (nat, nat)map)
      | Some val_map -> (
         let inner_value_opt : nat option = Map.find_opt elt val_map in
         match inner_value_opt with
         | None -> Map.update elt (Some(minted_amount)) val_map
         | Some val ->
            let _check_max_minted : unit = assert_with_error (val + minted_amount <= max) ErrorsExtension.max_minted_reached in
            Map.update elt (Some(val + minted_amount)) val_map
         )
      in
      Big_map.update sender_ (Some(new_inner_map)) acc
   in
   let new_minted_per_wallet = List.fold update_minted_per_wallet param.ids s.extension.minted_per_wallet in

   let new_extension : extension = { s.extension with total_supply=new_total_supply; minted_per_wallet = new_minted_per_wallet; } in

   let power (x, y : nat * nat) : nat =
      let rec multiply(acc, elt, last: nat * nat * nat ) : nat = if last = 0n then acc else multiply(acc * elt, elt, abs(last - 1n)) in
      multiply(1n, x, y)
   in

   // take 5% for minteed
   let initial_royalties = (Map.empty : (address, tez)map) in
   let apply_minteed_share(acc, elt: ((address, tez)map * (nat,tez)map) * (nat * tez)) : ((address, tez)map * (nat,tez)map) =
      let current_token_id = elt.0 in
      let current_amount = elt.1 in
      let minteed_ratio = s.extension.minteed_ratio in
      let _check_ratio_outofbound : unit = assert_with_error(minteed_ratio <= 100n) ErrorsExtension.invalid_minteed_ratio in
      let minteed_amount = current_amount * minteed_ratio / 100n in
      let minteed_address = s.extension.minteed in
      let alloc_to_spread = abs(100n - minteed_ratio) in
      let alloc_amount = current_amount * alloc_to_spread / 100n in
      //update computed royalties for minteed
      let acc_royalties = match (Map.find_opt minteed_address acc.0) with
      | None -> Map.add minteed_address minteed_amount acc.0
      | Some val -> Map.update minteed_address (Some (val + minteed_amount)) acc.0
      in
      //decrease amounts that will be taken into account for allocations
      let acc_amounts_by_id = match (Map.find_opt current_token_id acc.1) with
      | None -> failwith("ERROR should have an amount for this token_id")
      | Some _val -> Map.update current_token_id (Some (alloc_amount)) acc.1
      in
      (acc_royalties, acc_amounts_by_id)
   in
   let (royalties_with_minteed, amounts_by_id_after_minteed) = Map.fold apply_minteed_share amounts_by_id (initial_royalties, amounts_by_id) in

   // compute royalties by recipient
   let compute_royalties(acc, elt: (address, tez)map * (nat * tez)) : (address, tez)map =
      let current_token_id = elt.0 in
      let current_amount = elt.1 in
      //retrieve allocation for current token_id
      let (allocations, allocations_decimals) = match (Big_map.find_opt current_token_id s.extension.asset_infos) with
      | None -> (failwith(ErrorsExtension.missing_asset_info) : (address, nat)map * nat)
      | Some info -> (info.allocations, info.allocations_decimals)
      in
      // apply allocation to each token_id and aggregate by recipient
      let compute_distribution(acc_distrib, alloc : (address, tez)map * (address * nat)) : (address, tez)map =
         let recipient : address = alloc.0 in
         let recipient_ratio : nat = alloc.1 in
         let recipient_amount : tez = recipient_ratio * current_amount / power(10n, allocations_decimals) in
         match (Map.find_opt recipient acc_distrib) with
         | None -> Map.add recipient recipient_amount acc_distrib
         | Some val -> Map.update recipient (Some (val+recipient_amount)) acc_distrib
      in
      Map.fold compute_distribution allocations acc
   in
   let royalties = Map.fold compute_royalties amounts_by_id_after_minteed royalties_with_minteed in

   // prepare operation to send royalties
   let compute_operations(acc, elt : operation list * (address * tez)) : operation list =
      let dest_address : address = elt.0 in
      let dest_amount : tez = elt.1 in
      if (dest_amount > 0mutez) then
         let destination_opt : unit contract option = Tezos.get_contract_opt(dest_address) in
         let destination : unit contract = match destination_opt with
         | None -> (failwith("unknown address") : unit contract)
         | Some dest -> dest
         in
         (Tezos.transaction unit dest_amount destination) :: acc
      else
         acc
   in
   let ops : operation list = Map.fold compute_operations royalties ([] : operation list) in

   // redistribute to creator
   // let compute_distribution(acc, elt : operation list * (address * nat)) : operation list =
   //    let dest_address : address = elt.0 in
   //    let dest_amount : tez = (elt.1 * expected_amount / power(10n, s.extension.allocations_decimals)) in
   //    let destination_opt : unit contract option = Tezos.get_contract_opt(dest_address) in
   //    let destination : unit contract = match destination_opt with
   //    | None -> (failwith("unknown address") : unit contract)
   //    | Some dest -> dest
   //    in
   //    (Tezos.transaction unit dest_amount destination) :: acc
   // in
   // let ops : operation list = Map.fold compute_distribution s.extension.allocations ([] : operation list) in
   (ops, { s with ledger=new_ledger; extension=new_extension })
   //(([] : operation list), s)

type airdrop_param = [@layout:comb] {
   ids : Storage.token_id list;
   quantity : (Storage.token_id, nat) map;
   to : address
}

let airdrop (param: airdrop_param) (s: extension storage) : operation list * extension storage =
   let amount_ = Tezos.get_amount() in
   let _check_amount : unit = assert_with_error(amount_ = 0tez) ErrorsExtension.expects_0_tez in
   // update ledger and total_supply
   let set_token_owner (acc, elt : (Ledger.t * TotalSupply.t) * Storage.token_id) : (Ledger.t * TotalSupply.t) =
      let transfer_amount : nat = match (Map.find_opt elt param.quantity : nat option) with
      | None -> (failwith("quantity has not been defined for this token id") : nat)
      | Some val -> val
      in
      (
         Ledger.increase_token_amount_for_user acc.0 param.to elt transfer_amount,
         TotalSupply.decrease_reserved_for_token_id acc.1 elt transfer_amount
      )
   in
   let (new_ledger, new_total_supply) : (Ledger.t * TotalSupply.t) = List.fold set_token_owner param.ids (s.ledger, s.extension.total_supply) in
   let new_extension : extension = { s.extension with total_supply=new_total_supply } in
   (([]: operation list), { s with ledger=new_ledger; extension=new_extension })

let changeCollectionMetadata (new_metadata: bytes) (s: extension storage) : operation list * extension storage =
   // TODO: prevent this change if an asset has been sold
   let newMetadataMap : (string, bytes) big_map = Big_map.literal [(("contents" : string), new_metadata)] in
   let new_extension : extension = { s.extension with metadata=newMetadataMap; } in
   (([]: operation list), { s with extension = new_extension })

let changeTokenMetadata (p_tokenID, p_newIpfsURI : nat * bytes)(s: extension storage) : operation list * extension storage =
   // TODO: prevent this change if an asset has been sold
   let new_tokenID : nat = p_tokenID in
   let token_newIpfsURI : bytes = p_newIpfsURI in
   let new_tokenInfoMap : (string, bytes) map = Map.literal [(("" : string), (token_newIpfsURI))] in
   let token_infoRecord : TokenMetadata.data = {token_id = new_tokenID; token_info = new_tokenInfoMap} in
   (([]: operation list), { s with token_metadata = Big_map.literal [(new_tokenID, token_infoRecord)] })

let switchOpenMint (p_tokenID : nat)(s: extension storage) : operation list * extension storage =
   let current_asset_info : asset_info = match Big_map.find_opt p_tokenID s.extension.asset_infos with
   | None -> failwith ErrorsExtension.missing_asset_info
   | Some info -> info
   in
   let modified = Big_map.update p_tokenID (Some { current_asset_info with is_mintable=(not current_asset_info.is_mintable) }) s.extension.asset_infos in
   let new_extension : extension = { s.extension with asset_infos=modified; } in
   (([]: operation list), { s with extension=new_extension })


type changeallocation_param = {
   token_id : nat;
   allocations : (address, nat)map;
   allocations_decimals : nat;
}

let changeAllocation (param : changeallocation_param)(s: extension storage) : operation list * extension storage =
   let current_asset_info : asset_info = match Big_map.find_opt param.token_id s.extension.asset_infos with
   | None -> failwith ErrorsExtension.missing_asset_info
   | Some info -> info
   in
   let modified = Big_map.update param.token_id (Some { current_asset_info with allocations=param.allocations; allocations_decimals=param.allocations_decimals }) s.extension.asset_infos in
   let new_extension : extension = { s.extension with asset_infos=modified; } in
   (([]: operation list), { s with extension=new_extension })

type changeMinteedWallet_param = {
   addr : address;
   ratio : nat
}

let changeMinteedWallet (param : changeMinteedWallet_param)(s: extension storage) : operation list * extension storage =
   let new_extension : extension = { s.extension with minteed=param.addr; minteed_ratio=param.ratio} in
   (([]: operation list), { s with extension=new_extension })

type parameter = [@layout:comb]
   | Transfer of NFT.transfer
   | Balance_of of NFT.balance_of
   | Update_operators of NFT.update_operators
   | Premint of premint_param
   | Mint of mint_param
   | Airdrop of airdrop_param
   | ChangeCollectionMetadata of bytes
   | ChangeTokenMetadata of (nat * bytes)
   | SwitchOpenMint of nat
   | ChangeAllocation of changeallocation_param
   | ChangeMinteedWallet of changeMinteedWallet_param

let main (p, s : parameter * extension storage) : operation list * extension storage =
   match p with
      Transfer                  p -> let o1, s = NFT.transfer p s in
                                     let o2, s = transfer_extension p s in
                                     let o = List.fold_left (fun ((a,x):operation list * operation) -> x :: a) o2 o1 in
                                     o, s
   |  Balance_of                p -> NFT.balance_of p s
   |  Update_operators          p -> NFT.update_ops p s
   |  Mint                      p -> mint p s
   |  Airdrop                   p -> let _ = authorize_admin s in
                                     airdrop p s
   |  Premint                    p -> let _ = authorize_admin_and_creator s in
                                 premint p s
   |  ChangeCollectionMetadata   p -> let _ = authorize_admin_and_creator s in
                                      changeCollectionMetadata p s
   |  ChangeTokenMetadata        p -> let _ = authorize_admin_and_creator s in
                                      changeTokenMetadata p s
   |  SwitchOpenMint             p -> let _ = authorize_admin_and_creator s in
                                      switchOpenMint p s
   |  ChangeAllocation           p -> let _ = authorize_admin s in
                                      changeAllocation p s
   |  ChangeMinteedWallet        p -> let _ = authorize_minteed s in
                                      changeMinteedWallet p s

[@view] let get_balance (p, s : (Address.t * nat) * extension storage) : nat =
      let (owner, token_id) = p in
      let balance_ = NFT.Storage.get_balance s owner token_id in
      balance_

// [@view] let total_supply ((token_id, s) : (nat * extension storage)):  nat =
//       let () = NFT.Storage.assert_token_exist s token_id in
//       1n

// [@view] let all_tokens ((_, s) : (unit * extension storage)): nat list =
//    s.token_ids

// [@view] let is_operator ((op, s) : (NFT.operator * extension storage)): bool =
//       NFT.Operators.is_operator (s.operators, op.owner, op.operator, op.token_id)

// [@view] let token_metadata ((p, s) : (nat * extension storage)): NFT.TokenMetadata.data =
//       NFT.TokenMetadata.get_token_metadata p s.token_metadata
