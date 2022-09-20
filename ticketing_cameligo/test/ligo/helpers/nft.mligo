#import "../../../src/generic_fa2/core/instance/NFT.mligo" "NFT"
#import "./assert.mligo" "Assert"

(* Some types for readability *)
type nft_ext = NFT.extension
type nft_storage = NFT.storage
type extended_storage = nft_ext nft_storage

type taddr = (NFT.parameter, extended_storage) typed_address
type contr = NFT.parameter contract
type originated = {
    addr: address;
    taddr: taddr;
    contr: contr;
}

(* Some dummy values intended to be used as placeholders *)
let dummy_token_info =
    Map.literal [("",
      Bytes.pack "ipfs://QmbKq7QriWWU74NSq35sDSgUf24bYWTgpBq3Lea7A3d7jU")]

(* Base NFT storage *)
let base_storage (admin, creator, minteed : address * address * address) : extended_storage = {
    ledger = (Big_map.empty : NFT.Ledger.t);
    token_metadata = (Big_map.empty : NFT.TokenMetadata.t);
    operators = (Big_map.empty : NFT.Storage.Operators.t);
    token_ids = ([] : NFT.Storage.token_id list);

    (* extension *)
    extension = {
        admin = admin;
        creator = creator;
        minteed = minteed;
        minteed_ratio = 5n;
        total_supply = (Big_map.empty : NFT.TotalSupply.t);
        metadata = (Big_map.empty : (string, bytes) big_map);
        next_token_id=0n;
        minted_per_wallet = (Big_map.empty : (address, (nat, nat)map) big_map); 
        asset_infos = (Big_map.empty : (nat, NFT.asset_info) big_map);
    }
}

(* Originate an NFT contract with given init_storage storage *)
let originate (init_storage : extended_storage) =
    let (taddr, _, _) = Test.originate NFT.main init_storage 0mutez in
    let contr = Test.to_contract taddr in
    let addr = Tezos.address contr in
    {addr = addr; taddr = taddr; contr = contr}

(*
    Originate an NFT contract with given init_storage storage
    Use this one if you need access to views
*)
let originate_from_file (init_storage : extended_storage) =
    let f = "./src/generic_fa2/core/instance/NFT.mligo" in
    let v_mich = Test.run (fun (x:extended_storage) -> x) init_storage in
    let (addr, _, _) = Test.originate_from_file f "main" ["get_balance"] v_mich 0tez in
    let taddr : taddr = Test.cast_address addr in
    let contr = Test.to_contract taddr in
    {addr = addr; taddr = taddr; contr = contr}

(* Call entry point of NFT contr contract *)
let call (p, contr : NFT.parameter * contr) =
    Test.transfer_to_contract contr p 0mutez

(* Call entry point of NFT contr contract with amount *)
let call_with_amount (p, amount_, contr : NFT.parameter * tez * contr) =
    Test.transfer_to_contract contr p amount_

(* Entry points call helpers *)
let premint (p, contr : NFT.premint_param * contr) = call(Premint(p), contr)
let mint (p, amount_, contr : NFT.mint_param * tez * contr) =
    call_with_amount(Mint(p), amount_, contr)
let airdrop (p, contr : NFT.airdrop_param * contr) =
    call(Airdrop(p), contr)
let changeallocation (p, contr : NFT.changeallocation_param * contr) =
    call(ChangeAllocation(p), contr)
let changeminteedwallet (p, contr : NFT.changeMinteedWallet_param * contr) =
    call(ChangeMinteedWallet(p), contr)

let update_operators (p, contr : NFT.NFT.update_operators * contr) =
    call(Update_operators(p), contr)

(* Asserter helper for successful entry point calls *)
let premint_success (p, contr : NFT.premint_param * contr) =
    Assert.tx_success (premint(p, contr))

let mint_success (p, amount_, contr : NFT.mint_param * tez * contr) =
    Assert.tx_success (mint(p, amount_, contr))

let airdrop_success (p, contr : NFT.airdrop_param * contr) =
    Assert.tx_success (airdrop(p, contr))

let changeallocation_success (p, contr : NFT.changeallocation_param * contr) =
    Assert.tx_success (changeallocation(p, contr))

let changeminteedwallet_success(p, contr : NFT.changeMinteedWallet_param * contr) =
    Assert.tx_success (changeminteedwallet(p, contr))

let update_operators_success (p, contr : NFT.NFT.update_operators * contr) =
    Assert.tx_success (update_operators(p, contr))

(* assert NFT contract at [taddr] have [owner] address, token id pair with [amount_] in its ledger *)
let assert_balance (taddr, owned, amount_ :
   taddr * (NFT.Ledger.owner * NFT.Ledger.token_id) * nat) =
    let s = Test.get_storage taddr in
    match Big_map.find_opt owned s.ledger with
        Some tokens -> assert(tokens = amount_)
        | None -> failwith("Big_map key should not be missing")

(* assert NFT contract at [taddr] have [token_id] initial price of [amount_] *)
let assert_price (taddr, token_id, expected_price : taddr * nat * tez) =
    let s = Test.get_storage taddr in
    match Big_map.find_opt token_id s.extension.asset_infos with
    | Some asset_info -> assert(asset_info.initial_price = expected_price)
    | None -> failwith("Big_map key should not be missing")
       

(* assert NFT contract at [taddr] have [token_id] initial supply of [amount_] *)
let assert_total_supply (taddr, token_id, amount_ : taddr * nat * nat) =
    let s = Test.get_storage taddr in
    match Big_map.find_opt token_id s.extension.total_supply with
        Some supply -> assert(supply.total = amount_)
        | None -> failwith("Big_map key should not be missing")

let assert_available_supply (taddr, token_id, amount_ : taddr * nat * nat) =
    let s = Test.get_storage taddr in
    match Big_map.find_opt token_id s.extension.total_supply with
        Some supply -> assert(supply.available = amount_)
        | None -> failwith("Big_map key should not be missing")

let assert_reserved_supply (taddr, token_id, amount_ : taddr * nat * nat) =
    let s = Test.get_storage taddr in
    match Big_map.find_opt token_id s.extension.total_supply with
        Some supply -> assert(supply.reserved = amount_)
        | None -> failwith("Big_map key should not be missing")

(* assert NFT contract at [taddr] have [token_id] initial mintable of [expected_mintable] *)
let assert_is_mintable (taddr, token_id, expected_mintable : taddr * nat * bool) =
    let s = Test.get_storage taddr in
    match Big_map.find_opt token_id s.extension.asset_infos with
    | Some asset_info -> assert(asset_info.is_mintable = expected_mintable)
    | None -> failwith("Big_map key should not be missing")

(* assert NFT contract at [taddr] have [token_id] initial max_per_wallet of [expected_max_per_wallet] *)
let assert_max_per_wallet (taddr, token_id, expected_max_per_wallet : taddr * nat * nat) =
    let s = Test.get_storage taddr in
    match Big_map.find_opt token_id s.extension.asset_infos with
    | Some asset_info -> assert(asset_info.max_per_wallet = expected_max_per_wallet)
    | None -> failwith("Big_map key should not be missing")


(* assert NFT contract at [taddr] have [token_id] allocations for a [recipient] address of [expected_ratio] *)
let assert_allocation (taddr, token_id, recipient, expected_ratio : taddr * nat * address * nat) =
    let s = Test.get_storage taddr in
    match Big_map.find_opt token_id s.extension.asset_infos with
    | None -> failwith("Big_map key should not be missing")
    | Some asset_info -> (
        match Map.find_opt recipient asset_info.allocations with
        | None -> failwith("Recipient is not registered in allocations")
        | Some ratio -> assert(ratio = expected_ratio)
    ) 

(* assert NFT contract at [taddr] have [token_id] initialuuid of [expected_uuid] *)
let assert_uuid (taddr, token_id, expected_uuid : taddr * nat * string option) =
    let s = Test.get_storage taddr in
    match Big_map.find_opt token_id s.extension.asset_infos with
    | Some asset_info -> assert(asset_info.uuid = expected_uuid)
    | None -> failwith("Big_map key should not be missing")

(* assert NFT contract at [taddr] have [token_id] initial mintable of [expected_mintable] *)
let assert_minteedwallet (taddr, expected_minteed_wallet : taddr * address) =
    let s = Test.get_storage taddr in
    assert(s.extension.minteed = expected_minteed_wallet)
