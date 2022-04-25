
#import "../contracts/main.mligo" "Factory"
#import "../contracts/marketplace/main.mligo" "Marketplace"

type fa2_storage = Factory.NFT_FA2.Storage.t
type ext = Factory.NFT_FA2.extension
type ext_fa2_storage = ext fa2_storage

let assert_string_failure (res : test_exec_result) (expected : string) : unit =
  let expected = Test.eval expected in
  match res with
  | Fail (Rejected (actual,_)) -> assert (Test.michelson_equal actual expected)
  | Fail _ -> failwith "contract failed for an unknown reason"
  | Success _ -> failwith "contract did not failed but was expected to fail"

let test =
    // setup 4 accounts 
    let () = Test.reset_state 4n ([] : tez list) in
    let alice: address = Test.nth_bootstrap_account 0 in
    let bob: address = Test.nth_bootstrap_account 1 in
    let steven: address = Test.nth_bootstrap_account 2 in
    let frank: address = Test.nth_bootstrap_account 3 in

    // originate Factory smart contract
    let init_storage : Factory.Storage.t = { 
        all_collections=(Big_map.empty : (Factory.Storage.collectionContract, Factory.Storage.collectionOwner) big_map);
        owned_collections=(Big_map.empty : (Factory.Storage.collectionOwner, Factory.Storage.collectionContract list) big_map);
    } in
    let (addr,_,_) = Test.originate Factory.main init_storage 0tez in

    // originate Marketplace smart contract
    let marketplace_init_storage : Marketplace.Storage.t = { 
        next_sell_id=0n;
        active_proposals=(Set.empty : nat set);
        sell_proposals=(Big_map.empty : (nat, Marketplace.Storage.sell_proposal) big_map);
    } in
    let (marketplace_taddr,_,_) = Test.originate Marketplace.main marketplace_init_storage 0tez in


    let _generates_collection_1_should_works = 
        let () = Test.log("_generates_collection_1_should_works") in

        let x : Factory.parameter contract = Test.to_contract addr in

        // prepare arguments for generating a new collection
        let token_ids : nat list = [1n] in
        let token_info_1 = (Map.literal[
            ("QRcode", 0x623d82eff132);
            ("author", Bytes.pack frank); 
        ] : (string, bytes) map) in
        let token_metadata = (Big_map.literal [
            (1n, ({token_id=1n;token_info=token_info_1;} : Factory.NFT_FA2.Storage.TokenMetadata.data));
        ] : Factory.NFT_FA2.Storage.TokenMetadata.t) in

        // call GenerateCollection entrypoint
        let () = Test.set_source alice in
        let gencol_args : Factory.Parameter.generate_collection_param = {name="alice_collection_1"; token_ids=token_ids; token_metas=token_metadata} in
        let _ = Test.transfer_to_contract_exn x (GenerateCollection(gencol_args)) 1000000mutez in

        // verify FA2 has been created
        let s : Factory.storage = Test.get_storage addr in
        let colls : address list = match Big_map.find_opt alice s.owned_collections with
        | None -> ([] : address list)
        | Some x -> x
        in
        let owned_coll_size = List.fold (fun(acc, elt : nat * address) : nat -> acc + 1n) colls 0n in
        //let owned_coll_size : nat = Set.size colls in 
        let () = assert (owned_coll_size = 1n) in


        let () = Test.log("_marketplace_sell_token1_should_works") in
        // retrieve address collection
        let s_before : Factory.storage = Test.get_storage addr in
        let colls_before : address list = match Big_map.find_opt alice s_before.owned_collections with
        | None -> ([] : address list)
        | Some x -> x
        in
        let fa2_address : address = Option.unopt (List.head_opt colls_before) in
        let taddr_fa2_address = (Test.cast_address fa2_address : (Factory.NFT_FA2.parameter, ext_fa2_storage) typed_address) in
        let fa2_store : ext_fa2_storage = Test.get_storage taddr_fa2_address in
        let () = assert(Factory.NFT_FA2.Storage.is_owner_of fa2_store alice 1n) in
        let () = Test.log(fa2_store) in

        // APPROVE marketplace to transfer token 1
        let () = Test.set_source alice in
        let marketplace_contract : Marketplace.parameter contract = Test.to_contract marketplace_taddr in
        let marketplace_addr  = Tezos.address marketplace_contract in 
        let () = Test.log(marketplace_addr) in
        let fa2_contract : Factory.NFT_FA2.parameter contract = Test.to_contract taddr_fa2_address in
        let update_op : Factory.NFT_FA2.NFT.update_operators = [Add_operator({owner=alice; operator=marketplace_addr; token_id=1n})] in
        let _ = Test.transfer_to_contract_exn fa2_contract (Update_operators(update_op)) 0mutez in

        // alice Sell token1
        let sell_args : Marketplace.Parameter.sell_proposal_param = { 
            token_id=1n;
            collectionContract=fa2_address;
            price=1tez;
        } in
        let () = Test.set_source alice in
        let _ = Test.transfer_to_contract_exn marketplace_contract (Sell(sell_args)) 0mutez in

        // bob Buy token1
        let buy_args : Marketplace.Parameter.buy_param = { 
            proposal_id=0n;
        } in
        let () = Test.set_source bob in
        let buy_amount = sell_args.price + fa2_store.extension.royalties in 
        let _ = Test.transfer_to_contract_exn marketplace_contract (Buy(buy_args)) buy_amount in

        let fa2_store_after : ext_fa2_storage = Test.get_storage taddr_fa2_address in
        let () = assert(Factory.NFT_FA2.Storage.is_owner_of fa2_store_after bob 1n) in
        let () = Test.log(fa2_store_after) in
        "OK"
    in
    ()