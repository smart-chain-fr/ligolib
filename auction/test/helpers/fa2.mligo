#import "../../contracts/fa2/fa2.mligo" "FA2"

type taddr = (FA2.parameter, FA2.storage) typed_address
type contr = FA2.parameter contract
type originated = {
    addr: address;
    taddr: taddr;
    contr: contr;
}

(* Base Marketplace storage *)
let base_storage(param_token_id, _param_total_supply, param_init_ledger : nat * nat * (address, nat)map) : FA2.storage = 
    let add_account_balance(acc, elt : FA2.Ledger.t * (address * nat)) : FA2.Ledger.t =
        Big_map.add (elt.0, param_token_id) elt.1 acc
    in 
    let init_ledger = Map.fold add_account_balance param_init_ledger (Big_map.empty : FA2.Ledger.t) in
    {
        ledger=init_ledger;
        token_metadata=Big_map.literal[(param_token_id, { token_id=param_token_id;token_info=(Map.empty : (string,bytes)map) })];
        operators =(Big_map.empty : FA2.Operators.t);
    }

(* Originate a Marketplace contract with given init_storage storage *)
let originate (init_storage : FA2.storage) =
    //let (taddr, _, _) = Test.originate FA1.main init_storage 0mutez in
    // let contr = Test.to_contract taddr in
    // let addr = Tezos.address contr in
    let ist = Test.compile_value(init_storage) in
    let (addr, _, _) = Test.originate_from_file "contracts/fa2/fa2.mligo" "main" (["get_balance"] : string list) ist 0mutez in
    let taddr = (Test.cast_address(addr) : (FA2.parameter,FA2.storage)typed_address) in
    let contr = Test.to_contract(taddr) in
    {addr = addr; taddr = taddr; contr = contr}

(* Call entry point of Marketplace contr contract *)
let call (p, contr : FA2.parameter * contr) =
    Test.transfer_to_contract contr p 0mutez

(* Call entry point of Marketplace contr contract with amount *)
let call_with_amount (p, amount_, contr : FA2.parameter * tez * contr) =
    Test.transfer_to_contract contr p amount_