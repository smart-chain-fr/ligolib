#import "tezos-ligo-fa2/lib/fa2/asset/single_asset.mligo" "SingleAsset"
#import "tezos-ligo-fa2/test/fa2/single_asset.test.mligo" "SingleAsset_helper"
#import "tezos-ligo-fa2/test/helpers/list.mligo" "List_helper"
#import "./assert.mligo" "Assert"

(* Some types for readability *)
type taddr = (SingleAsset.parameter, SingleAsset.storage) typed_address
type contr = SingleAsset.parameter contract
type originated = {
    addr: address;
    taddr: taddr;
    owners: address list;
    ops: address list;
    contr: contr;
}

let originate (tok_amount : nat) = 
    let f = "./test/bootstrap/single_asset.mligo" in
    let init_storage, owners, ops = SingleAsset_helper.get_initial_storage(
        tok_amount, tok_amount, tok_amount
    ) in
    let v_mich = Test.run (fun (x:SingleAsset.Storage.t) -> x) init_storage in
    let (addr, _, _) = Test.originate_from_file f "main" (["total_supply"]: string list) v_mich 0tez in
    let taddr : taddr = Test.cast_address addr in
    let contr = Test.to_contract taddr in
    {
        addr = addr;
        taddr = taddr;
        owners = owners;
        ops = ops;
        contr = contr;
    }

type single_asset_transfer_param = {
    contr: contr;
    source: address;
    from: address;
    to: address;
    amount: nat;
}

(* Transfer token in [contr] between [from_] and [to_] addresses with [amount_] tokens,
 WARNING: changes Test framework source  *)
let transfer (contr, from_, to_, amount_ : contr * address * address * nat) = 
    let () = Test.set_source from_ in
    let transfer_requests = ([
      ({from_=from_; tx=([{to_=to_;amount=amount_}] : SingleAsset.atomic_trans list)});
    ] : SingleAsset.transfer) in
    Test.transfer_to_contract_exn contr (Transfer transfer_requests) 0tez

(* Batch add [operators] to [contr] contract *)
let add_operators (operators, contr : SingleAsset.operator list * SingleAsset.parameter contract) =
    let f (ys,x : (SingleAsset.unit_update list * SingleAsset.operator)) : SingleAsset.unit_update list = Add_operator(x) :: ys in
    let add_operator = List.fold_left f ([] : SingleAsset.unit_update list) operators in
    let r = Test.transfer_to_contract contr (Update_operators(add_operator)) 0mutez in
    Assert.tx_success r

(* assert for FA2 insuffiscient balance string failure *)
let assert_ins_balance_failure (r : test_exec_result) =  
    Assert.string_failure r SingleAsset.Errors.ins_balance

(* assert FA2 contract at [taddr] have [owner] address with [amount_] tokens in its ledger *)
let assert_balance_amount (taddr, owner, amount_ : taddr * SingleAsset.Ledger.owner *  nat) =
    let s = Test.get_storage taddr in
    match Big_map.find_opt owner s.ledger with
        Some tokens -> assert(tokens = amount_)
        | None -> failwith("Big_map key should not be missing")

(** 
    Pack a transfer lambda for token contract at address [addr] 
    between [from_] and [to_] addresses with [amount_] tokens
*)
let pack_transfer (addr, from_, to_, amount_ : address * address * address * nat) = 
    Bytes.pack (fun() -> 
        match (Tezos.get_entrypoint_opt "%transfer" addr : SingleAsset.transfer contract option) with
        Some(c) ->
            let transfer_requests = ([
              ({from_=from_; tx=([{to_=to_;amount=amount_}] : SingleAsset.atomic_trans list)});
            ] : SingleAsset.transfer) in
            let op = Tezos.transaction transfer_requests 0mutez c in [op]
        | None -> failwith("TOKEN_CONTRACT_NOT_FOUND")
    )
