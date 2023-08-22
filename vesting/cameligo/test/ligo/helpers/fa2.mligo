#import "../token/extended_fa2.mligo" "Token"
#import "./assert.mligo" "Assert"

(* Some types for readability *)
type taddr = (Token.parameter, Token.extended_storage) typed_address
type contr = Token.parameter contract
type originated = {
    addr: address;
    taddr: taddr;
    contr: contr;
}

let dummy_token_metadata (token_id : nat): Token.FA2.TokenMetadata.data = {
    token_id=token_id;
    token_info=Map.literal[("", 0x01)];
}

(* Base Token storage *)
let base_storage (token_id, beneficiary, beneficiary_amount : nat * address * nat) : Token.extended_storage = {
    ledger=(Big_map.literal[((beneficiary, token_id), beneficiary_amount)] : Token.FA2.Ledger.t);
    token_metadata=Big_map.literal[(token_id, dummy_token_metadata(token_id))];
    operators=(Big_map.empty : Token.FA2.Operators.t);
    metadata = (Big_map.empty : (string, bytes) big_map);
    extension = unit;
}

(* Originate a Token contract with given init_storage storage *)
let originate (init_storage : Token.extended_storage) =
    let (taddr, _, _) = Test.originate_uncurried Token.main init_storage 0mutez in
    let contr = Test.to_contract taddr in
    let addr = Tezos.address contr in
    {addr = addr; taddr = taddr; contr = contr}

let originate_from_file (init_storage, balance : Token.extended_storage * tez) =
    let f = "../token/extended_fa2.mligo" in
    let v_mich = Test.run (fun (x:Token.extended_storage) -> x) init_storage in
    let (addr, _, _) = Test.originate_from_file f "main" ["get_balance"] v_mich balance in
    let taddr : taddr = Test.cast_address addr in
    let contr = Test.to_contract taddr in
    {addr = addr; taddr = taddr; contr = contr}

(* Call entry point of Token contr contract *)
let call (p, contr : Token.parameter * contr) =
    Test.transfer_to_contract contr (p) 0mutez

let update_operators (p, contr : Token.FA2.update_operators * contr) =
    call(Update_operators(p), contr)

let update_operators_success (p, contr : Token.FA2.update_operators * contr) =
    Assert.tx_success(update_operators(p, contr))

let transfer (p, contr : Token.FA2.transfer * contr) =
    call(Transfer(p), contr)

let transfer_success (p, contr : Token.FA2.transfer * contr) =
    Assert.tx_success(transfer(p, contr))

let get_user_balance(taddr, owner : taddr * address) =
    let s = Test.get_storage taddr in
    Token.FA2.Ledger.get_for_user s.ledger owner

let assert_user_balance(taddr, owner, token_id, expected_balance : taddr * address * nat * nat) =
    let s = Test.get_storage taddr in
    let user_balance = Token.FA2.Ledger.get_for_user s.ledger owner token_id in
    // let () = Test.log(s) in 
    assert(user_balance = expected_balance)

let assert_user_balance_in_range(taddr, owner, token_id, expected_balance, epsilon : taddr * address * nat * nat * nat) =
    let s = Test.get_storage taddr in
    let user_balance = Token.FA2.Ledger.get_for_user s.ledger owner token_id in
    assert(abs(user_balance - expected_balance) <= epsilon)