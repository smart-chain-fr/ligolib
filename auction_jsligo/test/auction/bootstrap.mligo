
#import "../contracts/factory/main.mligo" "Factory"
#import "../../contracts/auction/main.jsligo" "Auction"
#import "../helpers/auction.mligo" "Auction_helper"
#import "../helpers/factory.mligo" "Factory_helper"
#import "../helpers/nft_multi.mligo" "NFT_MULTI_helper"

type fa2_storage = Factory.NFT_FA2.Storage.t
type ext = Factory.NFT_FA2.extension
type ext_fa2_storage = ext fa2_storage

let assert_string_failure (res : test_exec_result) (expected : string) : unit =
  let expected = Test.eval expected in
  match res with
  | Fail (Rejected (actual,_)) -> assert (Test.michelson_equal actual expected)
  | Fail (Balance_too_low _p) -> failwith "contract failed: balance too low"
  | Fail (Other s) -> failwith s
  | Success _gas -> failwith "contract did not failed but was expected to fail"

let bootstrap_accounts(current_timestamp : timestamp) =
    // setup 4 accounts 
    let year_2022 : timestamp = current_timestamp in
    let () = Test.reset_state_at year_2022 10n ([10000000tez; 100tez; 100tez; 100tez; 100tez; 100tez; 100tez; 100tez; 100tez; 10000000tez] : tez list) in
    let accountZero : address = Test.nth_bootstrap_account 0 in
    let accountOne : address = Test.nth_bootstrap_account 1 in
    let alice: address = Test.nth_bootstrap_account 2 in
    let bob: address = Test.nth_bootstrap_account 3 in
    let _steven: address = Test.nth_bootstrap_account 4 in
    let frank: address = Test.nth_bootstrap_account 5 in
    let reserve: address = Test.nth_bootstrap_account 6 in
    let royalties: address = Test.nth_bootstrap_account 7 in
    let admin: address = Test.nth_bootstrap_account 8 in
    let baker: address = Test.nth_bootstrap_account 9 in
    (alice, bob, reserve, royalties, admin, frank, baker, accountZero, accountOne)

let bootstrap_fa2_MULTI_NFT(param_admin, param_artist, param_token_ids, param_total_supply, param_init_ledger : address * address * nat list * (nat, nat)map * ((address * nat), nat)map) =
    let nft_multi_originated = NFT_MULTI_helper.originate(NFT_MULTI_helper.base_storage(param_admin, param_artist, param_token_ids, param_total_supply, param_init_ledger)) in 
    nft_multi_originated

let bootstrap_factory_NFT() =
    let factory_originated = Factory_helper.originate(Factory_helper.base_storage) in 
    factory_originated

let bootstrap_NFT_with_one_token(param_factory, param_admin, param_collection_name, param_token_metadata_key, param_token_metadata_value : Factory_helper.originated * address * string * string * bytes) = 
    // prepare arguments for generating a new collection
    let collection_name : string = param_collection_name in
    let token_ids : nat list = [1n] in
    let token_info_1 = (Map.literal[
        (param_token_metadata_key, param_token_metadata_value);
    ] : (string, bytes) map) in
    let token_metadata = (Big_map.literal [
        (1n, ({token_id=1n;token_info=token_info_1;} : Factory.NFT_FA2.Storage.TokenMetadata.data));
    ] : Factory.NFT_FA2.Storage.TokenMetadata.t) in

    // call GenerateCollection entrypoint
    let () = Test.set_source param_admin in
    let gencol_args : Factory.Parameter.generate_collection_param = {name=collection_name; token_ids=token_ids; token_metas=token_metadata} in
    let _ = Test.transfer_to_contract_exn param_factory.contr (GenerateCollection(gencol_args) : Factory.Parameter.t) 1mutez in

    // verify FA2 NFT contract has been created
    let factory_storage : Factory.storage = Test.get_storage param_factory.taddr in
    let colls : address list = match Big_map.find_opt param_admin factory_storage.owned_collections with
    | None -> ([] : address list)
    | Some x -> x
    in
    let owned_coll_size = List.fold (fun(acc, _elt : nat * address) : nat -> acc + 1n) colls 0n in
    let () = assert (owned_coll_size = 1n) in
    let fa2_nft_address : address = Option.unopt (List.head_opt colls) in
    let fa2_nft_taddress = (Test.cast_address fa2_nft_address : (Factory.NFT_FA2.parameter, ext_fa2_storage) typed_address) in
    let fa2_nft_contract = Test.to_contract fa2_nft_taddress in
    let fa2_nft_store : ext_fa2_storage = Test.get_storage fa2_nft_taddress in

    // verify ownership
    let () = assert(Factory.NFT_FA2.Storage.is_owner_of fa2_nft_store param_admin 1n) in
    {addr=fa2_nft_address; taddr=fa2_nft_taddress; contr=fa2_nft_contract}

let bootstrap_auction(param_admin, param_min_bd, param_commission_fee, param_reserve, param_royalties : address * nat * nat * address * address) =
    let auction_init_storage = Auction_helper.base_storage(param_admin, param_min_bd, param_commission_fee, param_reserve, param_royalties) in
    let auction_originated = Auction_helper.originate(auction_init_storage, 0mutez) in 
    auction_originated

let bootstrap_auction_with_storage(auction_partial_storage, init_balance : Auction.storage * tez) =
    let auction_init_storage = Auction_helper.fill_partial_storage(auction_partial_storage) in
    let auction_originated = Auction_helper.originate(auction_init_storage, init_balance) in 
    auction_originated

let bootstrap_full(auction_partial_storage_opt : Auction.storage option) =
    // setup accounts
    let (alice, bob, reserve, royalties, admin, frank, baker, accountZero, accountOne) = bootstrap_accounts(("2022-01-01t00:00:00Z" : timestamp)) in

    // originate FA2 NFT semi-fungible smart contract
    let nft_multi_init_ledger : ((address * nat), nat)map = Map.literal[((alice, 0n), 1000n); ((bob, 1n), 1000n)] in    
    let nft_multi_totalsupply : (nat, nat) map = Map.literal[(0n, 1000n); (1n, 1000n)] in 
    let nft_multi_originated = bootstrap_fa2_MULTI_NFT(alice, frank, [0n; 1n], nft_multi_totalsupply, nft_multi_init_ledger) in 

    // originate Factory smart contract
    let factory_originated = bootstrap_factory_NFT() in 

    // originate Auction smart contract
    // let auction_init_storage = match auction_partial_storage_opt with
    // | None -> Auction_helper.base_storage(admin, 10n, 2500n, reserve, royalties)
    // | Some partial -> Auction_helper.fill_partial_storage(partial, admin, 10n, 2500n, reserve, royalties)
    // in
    // let auction_originated = Auction_helper.originate(auction_init_storage) in 
    let auction_originated = match auction_partial_storage_opt with
    | None -> bootstrap_auction(admin, 10n, 2500n, reserve, royalties)
    | Some partial -> bootstrap_auction_with_storage(partial, 0mutez)
    in

    let fa2_nft_originated = bootstrap_NFT_with_one_token(factory_originated, alice, "alice_collection_1", "QRcode", 0x623d82eff132) in

    let bob_fa2_nft_originated = bootstrap_NFT_with_one_token(factory_originated, bob, "bob_collection_2", "QRcode", 0x49ca92efa18b) in

    (
        (alice, bob, reserve, royalties, admin, frank, baker, accountZero, accountOne),
        factory_originated,
        auction_originated,
        fa2_nft_originated, 
        nft_multi_originated,
        bob_fa2_nft_originated 
    )