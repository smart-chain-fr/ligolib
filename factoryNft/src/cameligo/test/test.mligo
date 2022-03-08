
#import "../contracts/main.mligo" "Factory"

let test =
    let () = Test.reset_state 4n ([] : tez list) in
    let alice: address = Test.nth_bootstrap_account 0 in
    let bob: address = Test.nth_bootstrap_account 1 in
    let steven: address = Test.nth_bootstrap_account 2 in
    let frank: address = Test.nth_bootstrap_account 3 in

    let init_storage : Factory.Storage.t = { 
        all_collections=(Big_map.empty : (Factory.Storage.collectionContract, Factory.Storage.collectionOwner) big_map);
        owned_collections=(Big_map.empty : (Factory.Storage.collectionOwner, Factory.Storage.collectionContract set) big_map);
    } in
    let (addr,_,_) = Test.originate Factory.main init_storage 0tez in
    let s_init = Test.get_storage addr in
    let () = Test.log(s_init) in


    let _generates_collection_should_works = 
        let () = Test.log("Test 1 starts") in

        let x : Factory.parameter contract = Test.to_contract addr in

        let () = Test.log("alice generates a collection") in
        let () = Test.set_source alice in
 
 
        let token_ids : nat list = [1n] in
        let token_info_1 = (Map.literal[
            ("QRcode", 0x623d82eff132);
        ] : (string, bytes) map) in
        let token_metadata = (Big_map.literal [
            (1n, ({token_id=1n;token_info=token_info_1;} : Factory.NFT_FA2.TokenMetadata.data));
        ] : Factory.NFT_FA2.TokenMetadata.t) in

        let gencol_args : Factory.Parameter.generate_collection_param = {name="alice_collection_1"; token_ids=token_ids; token_metas=token_metadata} in
        //let () = Test.log(gencol_args) in
        let _ = Test.transfer_to_contract_exn x (GenerateCollection(gencol_args)) 1000000mutez in

        let () = Test.log("check alice collections") in
        let s : Factory.storage = Test.get_storage addr in
        let colls : address set = match Big_map.find_opt alice s.owned_collections with
        | None -> (Set.empty : address set)
        | Some x -> x
        in
        let owned_coll_size : nat = Set.size colls in 
        let () = assert (owned_coll_size = 1n) in
        let print(i : address) : unit = Test.log(i) in 
        let () = Set.iter print colls in
        Test.log(s)
    in
    ()