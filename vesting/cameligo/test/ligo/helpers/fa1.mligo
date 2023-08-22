#import "../token/fa1.mligo" "Token"
#import "./assert.mligo" "Assert"

(* Some types for readability *)
type taddr = (Token.parameter, Token.storage) typed_address
type contr = Token.parameter contract
type originated = {
    addr: address;
    taddr: taddr;
    contr: contr;
}

let dummy_token_metadata (token_id : nat): Token.FA12.TokenMetadata.data = {
    token_id=token_id;
    token_info=Map.literal[("", 0x01)];
}

(* Base FA1 storage *)
let base_storage (ledger, token_metadata, total_supply, metadata : Token.FA12.Ledger.t * Token.FA12.TokenMetadata.t * nat * Token.FA12.Storage.Metadata.t) : Token.storage = {
    ledger = ledger;
    token_metadata = token_metadata;
    total_supply = total_supply;
    metadata = metadata;
}

(* Originate a FA1 contract with given init_storage storage *)
let originate (init_storage : Token.storage) =
    let (taddr, _, _) = Test.originate_uncurried Token.main init_storage 0mutez in
    let contr = Test.to_contract taddr in
    let addr = Tezos.address contr in
    {addr = addr; taddr = taddr; contr = contr}

(* Call entry point of FA1 contr contract *)
let call (p, contr : Token.parameter * contr) =
    Test.transfer_to_contract contr (p) 0mutez

let approve (p, contr : Token.FA12.approve * contr) =
    call(Approve(p), contr)

let approve_success (p, contr : Token.FA12.approve * contr) =
    Assert.tx_success(approve(p, contr))

let transfer (p, contr : Token.FA12.transfer * contr) =
    call(Transfer(p), contr)
    
let transfer_success (p, contr : Token.FA12.transfer * contr) =
    Assert.tx_success(transfer(p, contr))

let assert_user_balance(taddr, owner, expected_balance : taddr * address * nat) =
    let s = Test.get_storage taddr in
    let (user_balance, _) = Token.FA12.Ledger.get_for_user s.ledger owner in
    assert(user_balance = expected_balance)