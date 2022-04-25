(** 
   This file implement the TZIP-12 protocol (a.k.a FA2) for NFT on Tezos
   copyright Wulfman Corporation 2021
*)

#import "errors.mligo" "Errors"

(**
   This should be initialized at origination, conforming to either 
   TZIP-12 : https://gitlab.com/tezos/tzip/-/blob/master/proposals/tzip-12/tzip-12.md#token-metadata
   or TZIP-16 : https://gitlab.com/tezos/tzip/-/blob/master/proposals/tzip-12/tzip-12.md#contract-metadata-tzip-016 
*)
type data = {token_id:nat;token_info:(string,bytes)map}
type t = (nat, data) big_map 

let get_token_metadata (token_id : nat) (tm : t) =
   match Big_map.find_opt token_id tm with
      Some data -> data
   | None -> failwith Errors.undefined_token

let helper_add_global_metadata(acc , elt : (t * (string, bytes)map) * nat) : (t * (string, bytes)map) = 
   let current_metadata = match Big_map.find_opt elt acc.0 with
   | None -> (failwith(Errors.undefined_token) : data)
   | Some c -> c
   in
   let add_field(infos, field: (string, bytes)map * (string * bytes)) : (string, bytes)map = 
         match Map.find_opt field.0 infos with
         | None -> Map.add field.0 field.1 infos
         | Some _old -> infos 
   in
   let modified_current_token_info = Map.fold add_field acc.1 current_metadata.token_info in
   let modified_current_metadata : data = { current_metadata with token_info=modified_current_token_info } in
   (Big_map.update elt (Some(modified_current_metadata)) acc.0, acc.1)

let add_global_metadata (token_ids : nat list) (metadatas : t) (global_metadatas : (string, bytes) map) : t =
   let result, _gl_metas = List.fold helper_add_global_metadata token_ids (metadatas, global_metadatas) in
   result