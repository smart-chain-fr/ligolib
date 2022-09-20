#import "tezos-ligo-fa2/lib/fa2/asset/multi_asset.mligo" "FA2"
#import "./assert.mligo" "Assert"

(* Some types for readability *)
type taddr = (FA2.parameter, FA2.storage) typed_address
type contr = FA2.parameter contract
type originated = {
    addr: address;
    taddr: taddr;
    contr: contr;
}

let dummy_token_metadata (token_id : nat): FA2.TokenMetadata.data = {
    token_id=token_id;
    token_info=Map.literal[("", 0x01)];
}

(* Base FA2 storage *)
let base_storage (token_id, admin : nat * address) : FA2.storage = {
    ledger=(Big_map.literal[((admin, token_id), 1000n)] : FA2.Ledger.t);
    token_metadata=Big_map.literal[(token_id, dummy_token_metadata(token_id))];
    operators=(Big_map.empty : FA2.Operators.t);
}

(* Originate a FA2 contract with given init_storage storage *)
let originate (init_storage : FA2.storage) =
    let (taddr, _, _) = Test.originate FA2.main init_storage 0mutez in
    let contr = Test.to_contract taddr in
    let addr = Tezos.address contr in
    {addr = addr; taddr = taddr; contr = contr}

(* Call entry point of FA2 contr contract *)
let call (p, contr : FA2.parameter * contr) =
    Test.transfer_to_contract contr (p) 0mutez

let update_operators (p, contr : FA2.update_operators * contr) =
    call(Update_operators(p), contr)

let update_operators_success (p, contr : FA2.update_operators * contr) =
    Assert.tx_success(update_operators(p, contr))

let transfer (p, contr : FA2.transfer * contr) =
    call(Transfer(p), contr)

let transfer_success (p, contr : FA2.transfer * contr) =
    Assert.tx_success(transfer(p, contr))

let assert_user_balance(taddr, owner, token_id, expected_balance : taddr * address * nat * nat) =
    let s = Test.get_storage taddr in
    let user_balance = FA2.Ledger.get_for_user s.ledger owner token_id in
    assert(user_balance = expected_balance)