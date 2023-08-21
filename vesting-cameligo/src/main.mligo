#import "storage.mligo" "Storage"
#import "parameter.mligo" "Parameter"
#import "errors.mligo" "Errors"
#import "ligo-extendable-fa2/lib/multi_asset/fa2.mligo" "FA2"
// #import "tezos-ligo-fa2/lib/fa2/asset/multi_asset.mligo" "FA2"
// #import "tezos-ligo-fa2/lib/fa1.2/FA1.2.jsligo" "FA1"
#import "ligo_fa1.2/lib/asset/fa12.mligo" "FA1"


type storage = Storage.t
type parameter = Parameter.t
type return = operation list * storage

let make_fa1_transfer(from, to, token_address, amount : address * address * address * nat) : operation =
    let destination : FA1.transfer contract = match (Tezos.get_entrypoint_opt "%transfer" token_address : FA1.transfer contract option) with
    | None -> failwith "FA1 unknown transfer entrypoint"
    | Some ctr -> ctr
    in
    let payload : FA1.transfer = (from, (to, amount)) in
    Tezos.transaction payload 0mutez destination


let make_fa2_transfer(from, to, token_address, token_id, amount : address * address * address * nat * nat) : operation =
    let destination : FA2.transfer contract = match (Tezos.get_entrypoint_opt "%transfer" token_address : FA2.transfer contract option) with
    | None -> failwith "FA2 unknown transfer entrypoint"
    | Some ctr -> ctr
    in
    let payload : FA2.transfer = [{from_=from; txs=[{to_=to; token_id=token_id; amount=amount}]}] in
    Tezos.transaction payload 0mutez destination

let compute_releasable_amount(total_beneficiary, already_released, end_of_cliff, vesting_end, release_duration : nat * nat * timestamp * timestamp * nat) : nat =
    if (Tezos.get_now() - end_of_cliff < 0) then
        0n
    else if (Tezos.get_now() - vesting_end > 0) then
        abs(total_beneficiary - already_released)
    else 
        let ratio = abs(Tezos.get_now() - end_of_cliff) / release_duration in
        abs(total_beneficiary * ratio - already_released)


let start(_param, s : unit * storage) : operation list * storage =
    let _check_already_started : unit = assert_with_error (s.started = False) Errors.vesting_already_started in
    let _check_sender_admin : unit = assert_with_error (Tezos.get_sender() = s.admin) Errors.not_admin in
    let _check_vesting_duration : unit = assert_with_error (s.release_duration > 0n) Errors.vesting_duration_zero in
    let _check_vesting_duration_higher_than_cliff : unit = assert_with_error (s.release_duration >= s.cliff_duration) Errors.vesting_duration_smaller_than_cliff_duration in

    // compute vested_amount based on beneficiaries
    let sum_beneficiaries_amounts(acc, elt : nat * (address * nat)) : nat = acc + elt.1 in
    let vested_amount = Map.fold sum_beneficiaries_amounts s.beneficiaries 0n in
    // admin transfer funds to vesting contract
    let op = match s.token_address with
    | FA1 token_address -> make_fa1_transfer(Tezos.get_sender(), Tezos.get_self_address(), token_address, vested_amount)
    | FA2 token_address -> make_fa2_transfer(Tezos.get_sender(), Tezos.get_self_address(), token_address, s.token_id, vested_amount)
    in
    // setup timestamps
    let current_timestamp = Tezos.get_now() in
    let end_of_cliff_timestamp = current_timestamp + int(s.cliff_duration) in
    let start_timestamp = current_timestamp in
    let vesting_end_timestamp = current_timestamp + int(s.release_duration) in
    let modified_storage = { s with
        started = True; 
        vested_amount=vested_amount; 
        start=(Some(start_timestamp)); 
        vesting_end=(Some(vesting_end_timestamp)); 
        end_of_cliff=(Some(end_of_cliff_timestamp));
    }
    in
    ([op], modified_storage)

let revoke(_param, s : unit * storage) : operation list * storage =
    let _check_started : unit = assert_with_error (s.started = True) Errors.vesting_not_started in
    let _check_revocable : unit = assert_with_error (s.revocable = True) Errors.vesting_not_revocable in
    let _check_sender_admin : unit = assert_with_error (Tezos.get_sender() = s.admin) Errors.not_admin in
    let _check_not_revoked : unit = assert_with_error (s.revoked = False) Errors.vesting_already_revoked in
    let revokable_amount = abs(s.vested_amount - s.total_released) in
    let op = match s.token_address with
    | FA1 token_address -> make_fa1_transfer(Tezos.get_self_address(), s.admin, token_address, revokable_amount)
    | FA2 token_address -> make_fa2_transfer(Tezos.get_self_address(), s.admin, token_address, s.token_id, revokable_amount)
    in
    ([op], { s with revoked = True })

let revoke_beneficiary(param, s : Parameter.revoke_beneficiary_param * storage) : operation list * storage =
    let _check_started : unit = assert_with_error (s.started = True) Errors.vesting_not_started in
    let _check_revocable : unit = assert_with_error (s.revocable = True) Errors.vesting_not_revocable in
    let _check_sender_admin : unit = assert_with_error (Tezos.get_sender() = s.admin) Errors.not_admin in
    let _check_not_revoked : unit = assert_with_error (s.revoked = False) Errors.vesting_already_revoked in
    let already_revoked = match Map.find_opt param s.revoked_addresses with
    | None -> False
    | Some status -> status
    in
    let _check_address_not_revoked : unit = assert_with_error (already_revoked = False) Errors.address_already_revoked in

    let released_amount = match Map.find_opt param s.released with
    | None -> 0n
    | Some amt -> amt
    in
    let beneficiary_amount = match Map.find_opt param s.beneficiaries with
    | None -> 0n
    | Some amt -> amt
    in

    let to_send_to_admin = abs(beneficiary_amount - released_amount) in
    let op = match s.token_address with
    | FA1 token_address -> make_fa1_transfer(Tezos.get_self_address(), s.admin, token_address, to_send_to_admin)
    | FA2 token_address -> make_fa2_transfer(Tezos.get_self_address(), s.admin, token_address, s.token_id, to_send_to_admin)
    in
    let modified_storage = { s with 
        total_released=s.total_released + to_send_to_admin;
        revoked_addresses=Map.update param (Some(True)) s.revoked_addresses;
    } in
    ([op], modified_storage)

let release(_param, s : unit * storage) : operation list * storage =
    let sender = Tezos.get_sender() in
    let _check_is_started : unit = assert_with_error (s.started = True) Errors.vesting_not_started in
    let total_beneficiary_amount = match Map.find_opt sender s.beneficiaries with
    | None -> failwith Errors.sender_not_beneficiary
    | Some value -> value
    in
    let beneficiary_revoked = match Map.find_opt sender s.revoked_addresses with
    | None -> False
    | Some revoked -> revoked
    in
    let _check_is_not_revoked : unit = assert_with_error (beneficiary_revoked = False) Errors.beneficiary_revoked in
    
    // compute releasable amount
    let already_released_amount = match (Map.find_opt sender s.released) with
    | None -> 0n
    | Some released -> released
    in
    let releasable_amount = compute_releasable_amount(
        total_beneficiary_amount, 
        already_released_amount, 
        Option.unopt(s.end_of_cliff), 
        Option.unopt(s.vesting_end), 
        s.release_duration
    ) in
    let _check_nothing_to_release : unit = assert_with_error (releasable_amount > 0n) Errors.nothing_to_release in
    let modified_storage = { s with 
        total_released=s.total_released+releasable_amount;
        released=Map.update sender (Some(already_released_amount + releasable_amount)) s.released;
    } in
    let op = match s.token_address with
    | FA1 token_address -> make_fa1_transfer(Tezos.get_self_address(), sender, token_address, releasable_amount)
    | FA2 token_address -> make_fa2_transfer(Tezos.get_self_address(), sender, token_address, s.token_id, releasable_amount)
    in
    ([op], modified_storage)

let main(param, store : parameter * storage) : return =
    match param with
    | Start p -> start(p, store)
    | Revoke p -> revoke(p, store)
    | RevokeBeneficiary p -> revoke_beneficiary(p, store)
    | Release p -> release(p, store)
