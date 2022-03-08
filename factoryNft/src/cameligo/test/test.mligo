
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
    //let () = Test.log(s_init) in


    let _generates_collection_1_should_works = 
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
    let _generates_collection_5_should_works = 
        let () = Test.log("Test 1 starts") in

        let x : Factory.parameter contract = Test.to_contract addr in

        let () = Test.log("alice generates a collection") in
        let () = Test.set_source alice in
 
 
        let token_ids : nat list = [1n; 2n; 3n ;4n; 5n] in
        let token_info_1 = (Map.literal[ ("QRcode", 0x623d82eff132);] : (string, bytes) map) in
        let token_info_2 = (Map.literal[ ("QRcode", 0x49aa82eff132);] : (string, bytes) map) in
        let token_info_3 = (Map.literal[ ("QRcode", 0xab3442eff132);] : (string, bytes) map) in
        let token_info_4 = (Map.literal[ ("QRcode", 0xdeadbeefdead);] : (string, bytes) map) in
        let token_info_5 = (Map.literal[ ("QRcode", 0xdeadbeefbeef);] : (string, bytes) map) in

        let token_metadata = (Big_map.literal [
            (1n, ({token_id=1n;token_info=token_info_1;} : Factory.NFT_FA2.TokenMetadata.data));
            (2n, ({token_id=2n;token_info=token_info_2;} : Factory.NFT_FA2.TokenMetadata.data));
            (3n, ({token_id=3n;token_info=token_info_3;} : Factory.NFT_FA2.TokenMetadata.data));
            (4n, ({token_id=4n;token_info=token_info_4;} : Factory.NFT_FA2.TokenMetadata.data));
            (5n, ({token_id=5n;token_info=token_info_5;} : Factory.NFT_FA2.TokenMetadata.data));
        ] : Factory.NFT_FA2.TokenMetadata.t) in

        let gencol_args : Factory.Parameter.generate_collection_param = {name="alice_collection_1"; token_ids=token_ids; token_metas=token_metadata} in
        //let () = Test.log(gencol_args) in
        let _ = Test.transfer_to_contract_exn x (GenerateCollection(gencol_args)) 1000000mutez in

        let () = Test.log("check alice collections") in
        let s : Factory.storage = Test.get_storage addr in
        //let () = Test.log(s) in
        let colls : address set = match Big_map.find_opt alice s.owned_collections with
        | None -> (Set.empty : address set)
        | Some x -> x
        in
        let owned_coll_size : nat = Set.size colls in 
        let () = assert (owned_coll_size = 2n) in
        let print(i : address) : unit = Test.log(i) in 
        let () = Set.iter print colls in

        let func(acc, elt : (address, (nat list * Factory.NFT_FA2.TokenMetadata.t))big_map * address) : (address, (nat list * Factory.NFT_FA2.TokenMetadata.t))big_map = 
            let taddr = (Test.cast_address elt : (Factory.NFT_FA2.parameter, Factory.NFT_FA2.Storage.t) typed_address) in
            let fa2_store : Factory.NFT_FA2.Storage.t = Test.get_storage taddr in
            Big_map.add elt (fa2_store.token_ids, fa2_store.token_metadata) acc
        in
        let all_tokens : (address, (nat list * Factory.NFT_FA2.TokenMetadata.t))big_map = Set.fold func colls (Big_map.empty : (address, (nat list * Factory.NFT_FA2.TokenMetadata.t) )big_map) in 
        
        let colls_list : address list = Set.fold (fun(acc, i : address list * address) -> i :: acc) colls ([] : address list) in
        let address1 : address = Option.unopt (List.head_opt colls_list) in
        let address2 : address = Option.unopt (List.head_opt (Option.unopt (List.tail_opt colls_list))) in
        let collection1_info : nat list * Factory.NFT_FA2.TokenMetadata.t = match Big_map.find_opt address1 all_tokens with
        | None -> (failwith("") : nat list * Factory.NFT_FA2.TokenMetadata.t)
        | Some info -> info
        in
        let () = assert(collection1_info.0 = [1n]) in 
        let collection2_info : nat list * Factory.NFT_FA2.TokenMetadata.t = match Big_map.find_opt address2 all_tokens with
        | None -> (failwith("") : nat list * Factory.NFT_FA2.TokenMetadata.t)
        | Some info -> info
        in
        let () = assert(collection2_info.0 = [1n; 2n; 3n; 4n; 5n]) in 
        let collection2_metas : Factory.NFT_FA2.TokenMetadata.t = collection2_info.1 in
        let collection2_metas_tok3 : Factory.NFT_FA2.TokenMetadata.data = match Big_map.find_opt 3n collection2_metas with
        | None -> (failwith("") : Factory.NFT_FA2.TokenMetadata.data)
        | Some info -> info
        in
        let () = assert(collection2_metas_tok3.token_info = (Map.literal[ ("QRcode", 0xab3442eff132);] : (string, bytes) map)) in
        Test.log(collection2_metas_tok3.token_info)
    in

    ()