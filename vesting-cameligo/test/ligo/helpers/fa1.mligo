#import "tezos-ligo-fa2/lib/fa1.2/FA1.2.jsligo" "FA1"
#import "./assert.mligo" "Assert"

(* Some types for readability *)
type taddr = (FA1.parameter, FA1.storage) typed_address
type contr = FA1.parameter contract
type originated = {
    addr: address;
    taddr: taddr;
    contr: contr;
}

let dummy_token_metadata (token_id : nat): FA1.TokenMetadata.data = {
    token_id=token_id;
    token_info=Map.literal[("", 0x01)];
}

(* Base FA1 storage *)
let base_storage (token_id, admin : nat * address) : FA1.storage = 
let allowance = (Map.empty : FA1.Allowance.t) in
{
    ledger=(Big_map.literal[(admin, (1000n, (Map.empty : FA1.Allowance.t))) ] : FA1.Ledger.t);
    token_metadata=dummy_token_metadata(token_id);
    totalSupply=0n;
}

(* Originate a FA1 contract with given init_storage storage *)
let originate (init_storage : FA1.storage) =
    let (taddr, _, _) = Test.originate FA1.main init_storage 0mutez in
    let contr = Test.to_contract taddr in
    let addr = Tezos.address contr in
    {addr = addr; taddr = taddr; contr = contr}

(* Call entry point of FA1 contr contract *)
let call (p, contr : FA1.parameter * contr) =
    Test.transfer_to_contract contr (p) 0mutez

let approve (p, contr : FA1.approve * contr) =
    call(Approve(p), contr)

let approve_success (p, contr : FA1.approve * contr) =
    Assert.tx_success(approve(p, contr))

let transfer (p, contr : FA1.transfer * contr) =
    call(Transfer(p), contr)
    
let transfer_success (p, contr : FA1.transfer * contr) =
    Assert.tx_success(transfer(p, contr))