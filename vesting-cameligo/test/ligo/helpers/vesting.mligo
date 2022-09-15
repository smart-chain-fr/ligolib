#import "../../../src/main.mligo" "Vesting"
#import "./assert.mligo" "Assert"

(* Some types for readability *)
type taddr = (Vesting.parameter, Vesting.storage) typed_address
type contr = Vesting.parameter contract
type originated = {
    addr: address;
    taddr: taddr;
    contr: contr;
}

let zero_timestamp : timestamp = ("1970-01-01T00:00:01Z" : timestamp)

(* Base Factory storage *)
let base_storage (admin, token_address, token_id, beneficiaries, vesting_duration, revocable : address * Vesting.Storage.fa_type * nat * (address, nat)map * nat * bool) : Vesting.storage = {
    token_address=token_address;
    token_id=token_id;
    beneficiaries=beneficiaries;
    revocable=revocable;
    release_duration=vesting_duration;
    cliff_duration=1000n;
    admin = admin;
    released=(Map.empty : (address, nat) map);
    revoked=False;
    revoked_addresses=(Map.empty :(address, bool) map);
    vested_amount=0n;
    started=False;
    total_released=0n;
    end_of_cliff=(None : timestamp option);
    vesting_end=(None : timestamp option);
    start=(None : timestamp option);
    metadata = (Big_map.empty : (string, bytes) big_map);
}

(* Originate a Vesting contract with given init_storage storage *)
let originate (init_storage : Vesting.storage) =
    let (taddr, _, _) = Test.originate Vesting.main init_storage 0mutez in
    let contr = Test.to_contract taddr in
    let addr = Tezos.address contr in
    {addr = addr; taddr = taddr; contr = contr}

(* Call entry point of Factory contr contract *)
let call (p, contr : Vesting.parameter * contr) =
    Test.transfer_to_contract contr (p) 0mutez

let call_success (p, contr: Vesting.parameter * contr) =
    Assert.tx_success (call(p, contr))

(* Call entry point of NFT contr contract with amount *)
let call_with_amount (p, amount_, contr : Vesting.parameter * tez * contr) =
    Test.transfer_to_contract contr p amount_

let start (p, amount_, contr : unit * tez * contr) =
    call_with_amount(Start(p), amount_, contr)

let revoke (p, amount_, contr : unit * tez * contr) =
    call_with_amount(Revoke(p), amount_, contr)

let revoke_beneficiary (p, amount_, contr : Vesting.Parameter.revoke_beneficiary_param * tez * contr) =
    call_with_amount(RevokeBeneficiary(p), amount_, contr)

let release (p, amount_, contr : unit * tez * contr) =
    call_with_amount(Release(p), amount_, contr)

let start_success (p, amount_, contr : unit * tez * contr) =
    Assert.tx_success (start(p, amount_, contr))

let revoke_success (p, amount_, contr : unit * tez * contr) =
    Assert.tx_success (revoke(p, amount_, contr))

let revoke_beneficiary_success (p, amount_, contr : Vesting.Parameter.revoke_beneficiary_param * tez * contr) =
    Assert.tx_success (revoke_beneficiary(p, amount_, contr))

let release_success (p, amount_, contr : unit * tez * contr) =
    Assert.tx_success (release(p, amount_, contr))


// (* assert Factory contract at [taddr] have [owner] address with [size] collections *)
// let assert_owned_collections_size (taddr, owner, size : taddr * Factory.Storage.collectionOwner * nat) =
//     let s = Test.get_storage taddr in
//     match Big_map.find_opt owner s.owned_collections with
//         Some lst -> assert(List.size lst = size)
//         (* assert(lst.size = size) *)
//         | None -> failwith("Big_map key should not be missing")

let assert_vesting_started(taddr, expected_started : taddr * bool) = 
    let s = Test.get_storage taddr in
    assert(s.started = expected_started)

let assert_released_amount(taddr, owner, expected_released_amount : taddr * address * nat) =
    let s = Test.get_storage taddr in
    match Map.find_opt owner s.released with
    | None -> assert(0n = expected_released_amount)
    | Some released_amount -> assert(released_amount = expected_released_amount)


let assert_vesting_revoked(taddr, expected_revoked : taddr * bool) = 
    let s = Test.get_storage taddr in
    assert(s.revoked = expected_revoked)

let assert_beneficiary_revoked(taddr, beneficiary, expected_status : taddr * address * bool) = 
    let s = Test.get_storage taddr in
    match Map.find_opt beneficiary s.revoked_addresses with
    | None -> assert(expected_status = False)
    | Some status -> assert(status = expected_status)
