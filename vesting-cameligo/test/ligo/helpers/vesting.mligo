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

(* Base Factory storage *)
let base_storage (admin : address) : Vesting.storage = {
    admin = admin;
    metadata = (Big_map.empty : (string, bytes) big_map);
}

(* Originate a Factory contract with given init_storage storage *)
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

let entrypoint_1 (p, amount_, contr : Vesting.Parameter.entrypoint_1_param * tez * contr) =
    call_with_amount(Entrypoint_1(p), amount_, contr)

let entrypoint_1_success (p, amount_, contr : Vesting.Parameter.entrypoint_1_param * tez * contr) =
    Assert.tx_success (entrypoint_1(p, amount_, contr))

// (* assert Factory contract at [taddr] have [owner] address with [size] collections *)
// let assert_owned_collections_size (taddr, owner, size : taddr * Factory.Storage.collectionOwner * nat) =
//     let s = Test.get_storage taddr in
//     match Big_map.find_opt owner s.owned_collections with
//         Some lst -> assert(List.size lst = size)
//         (* assert(lst.size = size) *)
//         | None -> failwith("Big_map key should not be missing")

