#import "../../contracts/fa1/fa1.jsligo" "FA1"

type taddr = (FA1.parameter, FA1.storage) typed_address
type contr = FA1.parameter contract
type originated = {
    addr: address;
    taddr: taddr;
    contr: contr;
}

(* Base Marketplace storage *)
let base_storage(param_token_id, param_total_supply, param_init_ledger : nat * nat * (address, nat)map) : FA1.storage = 
    let add_account_balance(acc, elt : (address, (nat * (address, nat)map) ) big_map * (address * nat)) : (address, (nat * (address, nat)map) ) big_map =
        Big_map.add elt.0 (elt.1, (Map.empty : (address, nat)map)) acc
    in 
    let init_ledger = Map.fold add_account_balance param_init_ledger (Big_map.empty : (address, (nat * (address, nat)map) ) big_map) in
    {
        ledger=init_ledger;
        // ledger=Big_map.literal[()] : (address, (nat * (address, nat)map) ) big_map);
        // ledger=(Big_map.empty : (address, (nat * (address, nat)map) ) big_map);
        token_metadata= {
        token_id=param_token_id;
        token_info=(Map.empty : (string, bytes) map);
        };
        totalSupply=param_total_supply;
    }

(* Originate a Marketplace contract with given init_storage storage *)
let originate (init_storage : FA1.storage) =
    //let transpile_indice_func = (x:FA1.storage) -> x in
    //let ist = Test.run ( (fun(x: FA1.storage) -> x), init_storage ) in
    let ist = Test.compile_value(init_storage) in
    let (addr, _, _) = Test.originate_from_file "contracts/fa1/fa1.jsligo" "main" (["get_balance"] : string list) ist 0mutez in
    let taddr = (Test.cast_address(addr) : (FA1.parameter,FA1.storage)typed_address) in
    let contr = Test.to_contract(taddr) in
    {addr = addr; taddr = taddr; contr = contr}

(* Call entry point of Marketplace contr contract *)
let call (p, contr : FA1.parameter * contr) =
    Test.transfer_to_contract contr p 0mutez

(* Call entry point of Marketplace contr contract with amount *)
let call_with_amount (p, amount_, contr : FA1.parameter * tez * contr) =
    Test.transfer_to_contract contr p amount_