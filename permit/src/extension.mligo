#import "ligo-generic-fa2/lib/multi_asset/fa2.mligo" "FA2"
#import "./errors.mligo" "Errors"

type seconds = nat
type permit_key = (address * bytes)
type permits = (permit_key, timestamp) big_map
type user_expiries = (address, seconds option) big_map
type permit_expiries = (permit_key, seconds option) big_map

type t = {
    admin: address;
    counter: nat;
    default_expiry: seconds;
    max_expiry: seconds;
    permits: permits;
    user_expiries: user_expiries;
    permit_expiries: permit_expiries;
}

let get_expiry (ext: t) ((user, param_hash): permit_key) : seconds =
    match Big_map.find_opt (user, param_hash) ext.permit_expiries with
    | None ->
        begin
            match Big_map.find_opt user ext.user_expiries with
            | None -> ext.default_expiry
            | Some exp ->
                begin
                    match exp with
                    | None -> ext.default_expiry
                    | Some t -> t
                end
        end
    | Some p ->
        begin
            match p with
            | None -> ext.default_expiry
            | Some exp -> exp
        end

let assert_admin (ext : t) =
    assert_with_error (Tezos.get_sender() = ext.admin) Errors.requires_admin

let set_admin (ext : t) (admin:address) =
    let () = assert_admin(ext) in
    { ext with admin = admin }

let add_permit (ext : t) (permit_key: permit_key) =
    let now = Tezos.get_now() in
    { ext with
        permits = Big_map.add permit_key now ext.permits;
        counter = ext.counter + 1n
    }

let update_permit (ext : t) (permit_key: permit_key) =
    let now = Tezos.get_now() in
    { ext with
        permits = Big_map.update permit_key (Some(now)) ext.permits;
        counter = ext.counter + 1n
    }

let _check_not_expired (ext : t) (submission_timestamp: timestamp) (permit_key: permit_key) =
    let effective_expiry: seconds = get_expiry ext permit_key in
    if abs (Tezos.get_now() - submission_timestamp) < effective_expiry
    then failwith Errors.dup_permit

let transfer_presigned (ext : t) (params: FA2.transfer_from): bool * t =
    let params_hash = Crypto.blake2b (Bytes.pack params) in
    let permit_submit_time: timestamp =
        match Big_map.find_opt (params.from_, params_hash) ext.permits with
        | None -> (0: timestamp)
        | Some exp -> exp
    in
    if permit_submit_time = (0: timestamp)
    then
        (false, ext)
    else
        let effective_expiry =
            match Big_map.find_opt (params.from_, params_hash) ext.permit_expiries with
            | None ->
                begin
                    match Big_map.find_opt params.from_ ext.user_expiries with
                    | None -> (Some ext.default_expiry)
                    | Some exp -> exp
                end
            | Some exp -> exp
        in
        match effective_expiry with
        | None -> (failwith "NO_EXPIRY_FOUND": (bool * t))
        | Some effective_exp ->
            if abs ((Tezos.get_now()) - permit_submit_time) >= effective_exp
            then
                (false, { ext with permits = Big_map.remove (params.from_, params_hash) ext.permits })
            else
                (true, { ext with permits = Big_map.remove (params.from_, params_hash) ext.permits })
