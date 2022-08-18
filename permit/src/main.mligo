#import "ligo-generic-fa2/lib/multi_asset/fa2.mligo" "FA2"
#import "./constants.mligo" "Constants"
#import "./storage.mligo" "Storage"
#import "./extension.mligo" "Extension"
#import "./errors.mligo" "Errors"

type storage = Storage.t
type result = operation list * storage

type create_token = {
   token_id : nat;
   data     : FA2.TokenMetadata.data;
}

type mint_or_burn = [@layout:comb] {
   owner    : address;
   token_id : nat;
   amount_  : nat;
}

type permit_params = (key * (signature * bytes))
type expiry_params = (address * (nat * (bytes option)))

let create ({token_id;data},owner,amount : create_token * address * nat) (s : storage) =
   let () = Extension.assert_admin s.extension in
   let md = Storage.add_new_token s.token_metadata token_id data in
   let s = Storage.set_token_metadata s md in
   let ledger = FA2.Ledger.increase_token_amount_for_user s.ledger owner token_id amount in
   let s = FA2.Storage.set_ledger s ledger in
   ([]: operation list),s

let mint (lst : mint_or_burn list) (s : storage) =
   let () = Extension.assert_admin s.extension in
   let process_one (ledger,{owner;token_id;amount_} : FA2.Ledger.t * mint_or_burn) =
      let () = FA2.Storage.assert_token_exist  s token_id in
      FA2.Ledger.increase_token_amount_for_user ledger owner token_id amount_
   in
   let ledger = List.fold_left process_one s.ledger lst in
   let s = FA2.Storage.set_ledger s ledger in
   ([]: operation list),s

let burn (lst : mint_or_burn list) (s : storage) =
   let () = Extension.assert_admin s.extension in
   let process_one (ledger,{owner;token_id;amount_} : FA2.Ledger.t * mint_or_burn) =
      FA2.Ledger.decrease_token_amount_for_user ledger owner token_id amount_
   in
   let ledger = List.fold_left process_one s.ledger lst in
   let s = FA2.Storage.set_ledger s ledger in
   ([]: operation list),s

(* TZIP-17 *)
let permit (lst : (permit_params list)) (s : storage) =
    let process_permit (ext, permit : Extension.t * permit_params) =
        let (pub_key, (sig, hash_)) = permit in
        let packed = Bytes.pack (((Tezos.get_chain_id()), Tezos.get_self_address()), (ext.counter, hash_)) in
        if Crypto.check pub_key sig packed
        then
            let sender_ = Tezos.address (Tezos.implicit_account (Crypto.hash_key pub_key)) in
            let permit_key = sender_, hash_ in
            match Big_map.find_opt permit_key ext.permits with
            | None -> Extension.add_permit ext permit_key
            | Some submission_timestamp ->
                let () = Extension._check_not_expired s.extension submission_timestamp permit_key in
                Extension.update_permit ext permit_key
        else ([%Michelson ({| { FAILWITH } |} : string * bytes -> Extension.t)]) (Errors.missigned, packed)
    in
    let extension = List.fold_left process_permit s.extension lst in
    { s with extension = extension }

(* TZIP-17 *)
let set_expiry (p : expiry_params) (s : storage) =
    let (user_address, (seconds, permit_hash_opt)) = p in
    if seconds > s.extension.max_expiry
    then (failwith Errors.max_seconds_exceeded : storage)
    else if Tezos.get_sender() <> user_address
    then (failwith Errors.forbidden_expiry_update : storage)
    else
        let new_storage =
            match permit_hash_opt with
            | None ->
                {
                    s with extension.user_expiries = Big_map.add
                        user_address
                        (Some seconds)
                        s.extension.user_expiries
                }
            | Some permit_hash ->
                {
                    s with extension.permit_expiries = Big_map.add
                        (user_address, permit_hash)
                        (Some seconds)
                        s.extension.permit_expiries
                }
        in new_storage

(* TZIP-17 implementation of TZIP-12 Transfer *)
let transfer_permitted (t:FA2.transfer) (s: storage) =
    let make_transfer (acc, t : (FA2.Ledger.t * Extension.t) * FA2.transfer_from) =
        let (l, e) = acc in
        let (is_transfer_authorized, e) = Extension.transfer_presigned e t in
        List.fold
          (fun (acc, dst : (FA2.Ledger.t * Extension.t) * FA2.atomic_trans) ->
            let () = FA2.Storage.assert_token_exist s dst.token_id in
            let () = if not is_transfer_authorized then
                FA2.Operators.assert_authorisation s.operators t.from_ dst.token_id
            in
            let (ledger, ext) = acc in
            let ledger = FA2.Ledger.decrease_token_amount_for_user ledger t.from_ dst.token_id dst.amount in
            let ledger = FA2.Ledger.increase_token_amount_for_user ledger dst.to_ dst.token_id dst.amount in
            (ledger, ext)
          ) t.tx (l, e)
        in
    let (new_ledger, new_ext) = List.fold make_transfer t (s.ledger, s.extension)
    in { s with ledger = new_ledger; extension = new_ext }

type parameter = [@layout:comb]
    | Transfer of FA2.transfer
    | Balance_of of FA2.balance_of
    | Update_operators of FA2.update_operators
    | Create_token of create_token * address * nat
    | Mint_token of mint_or_burn list
    | Burn_token of mint_or_burn list
    | Permit of permit_params list
    | SetExpiry of expiry_params
    | SetAdmin of address

let main ((p,s):(parameter * storage)): result = match p with
   Transfer         p -> Constants.no_operation, transfer_permitted p s
|  Balance_of       p -> FA2.balance_of     p s
|  Update_operators p -> FA2.update_ops     p s
|  Create_token     p -> create             p s
|  Mint_token       p -> mint               p s
|  Burn_token       p -> burn               p s
|  Permit           p -> Constants.no_operation, permit p s
|  SetExpiry        p -> Constants.no_operation, set_expiry p s
|  SetAdmin         p -> Constants.no_operation, { s
    with extension = Extension.set_admin s.extension p }

(*
    Off-chain views required by TZIP-17

    Command to run to get the micheline expressions to put in the metadata:

    ligo compile expression cameligo '_get_counter' \
        --init-file src/main.mligo \
        --project-root . \
        --michelson-format json
*)
let _get_default_expiry ((_n,s):(nat * storage)) : nat =
    s.extension.default_expiry

let _get_counter ((_n,s):(nat * storage)) : nat =
    s.extension.counter

