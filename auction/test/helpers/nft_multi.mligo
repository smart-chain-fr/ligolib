#import "../../contracts/nft_multi/core/instance/NFT.mligo" "NFT_MULTI"

type contr = NFT_MULTI.parameter contract

type multi_ext = NFT_MULTI.extension
type multi_storage = NFT_MULTI.storage
type taddr = (NFT_MULTI.parameter, multi_ext multi_storage) typed_address
type originated = {
    addr: address;
    taddr: taddr;
    contr: contr;
}

(* Base Marketplace storage *)
let base_storage(param_admin, param_artist, param_token_ids, param_total_supply, param_init_ledger : address * address * nat list * (nat, nat)map * ((address * nat), nat)map) : multi_ext multi_storage = 
    // Initial ledger
    let add_account_balance(acc, elt : NFT_MULTI.Ledger.t * ((address * nat) * nat)) : NFT_MULTI.Ledger.t =
        Big_map.add (elt.0.0, elt.0.1) elt.1 acc
    in 
    let init_ledger = Map.fold add_account_balance param_init_ledger (Big_map.empty : NFT_MULTI.Ledger.t) in
    // Initial totalsupply
    let add_total_supply_token(acc, elt : NFT_MULTI.TotalSupply.t * (nat * nat)) : NFT_MULTI.TotalSupply.t =
        Big_map.add elt.0 elt.1 acc
    in 
    let init_total_supply = Map.fold add_total_supply_token param_total_supply (Big_map.empty : NFT_MULTI.TotalSupply.t) in 
    // Initial TokenMetadata
    let add_token_metadata(acc, elt : NFT_MULTI.TokenMetadata.t * nat) : NFT_MULTI.TokenMetadata.t =
        Big_map.add elt { token_id=elt;token_info=(Map.empty : (string,bytes)map) } acc
    in 
    let init_token_metadata = List.fold add_token_metadata param_token_ids (Big_map.empty : NFT_MULTI.TokenMetadata.t) in 
    {   
        ledger=init_ledger;
        //token_metadata=Big_map.literal[(param_token_id, { token_id=param_token_id;token_info=(Map.empty : (string,bytes)map) })];
        token_metadata=init_token_metadata;
        operators=(Big_map.empty : NFT_MULTI.Storage.Operators.t);
        token_ids=param_token_ids;
        extension={
            admin=param_admin;
            artist=param_artist;
            allocations=(Map.empty : (address, nat) map);
            allocations_decimals=3n;
            total_supply=init_total_supply;
            initial_prices=(Big_map.empty : (nat, tez) big_map);
            metadata=(Big_map.empty : (string, bytes) big_map);
        };
    }

(* Originate a Marketplace contract with given init_storage storage *)
let originate (init_storage : multi_ext multi_storage) =
    //let (taddr, _, _) = Test.originate FA1.main init_storage 0mutez in
    // let contr = Test.to_contract taddr in
    // let addr = Tezos.address contr in
    let ist = Test.compile_value(init_storage) in
    let (addr, _, _) = Test.originate_from_file "contracts/nft_multi/core/instance/NFT.mligo" "main" (["get_balance"; "total_supply"; "all_tokens"; "is_operator"; "token_metadata" ] : string list) ist 0mutez in
    let taddr = (Test.cast_address(addr) : (NFT_MULTI.parameter, multi_ext multi_storage)typed_address) in
    let contr = Test.to_contract(taddr) in
    {addr = addr; taddr = taddr; contr = contr}

(* Call entry point of Marketplace contr contract *)
let call (p, contr : NFT_MULTI.parameter * contr) =
    Test.transfer_to_contract contr p 0mutez

(* Call entry point of Marketplace contr contract with amount *)
let call_with_amount (p, amount_, contr : NFT_MULTI.parameter * tez * contr) =
    Test.transfer_to_contract contr p amount_