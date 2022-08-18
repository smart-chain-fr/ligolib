
#import "../contracts/main.mligo" "Factory"

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
            (1n, ({token_id=1n;token_info=token_info_1;} : Factory.NFT_FA2.NFT.TokenMetadata.data));
        ] : Factory.NFT_FA2.NFT.TokenMetadata.t) in

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
        assert (owned_coll_size = 1n)
    in
    let _mint_token2_collection_1_should_works = 
        let () = Test.log("_mint_token2_collection_1_should_works") in
        //let x : Factory.parameter contract = Test.to_contract addr in

        // Retrieve address of collection 1
        let s_before : Factory.storage = Test.get_storage addr in
        let colls_before : address list = match Big_map.find_opt alice s_before.owned_collections with
        | None -> ([] : address list)
        | Some oc -> oc
        in
        //let colls_before_list : address list = Set.fold (fun(acc, i : address list * address) -> i :: acc) colls_before ([] : address list) in
        let address1 : address = Option.unopt (List.head_opt colls_before) in

        // prepare mint arguments
        //let () = Test.log("alice mint token 2 in collection 1") in
        let extra_token_id : nat = 2n in
        let extra_token_ids : nat list = [extra_token_id] in
        let extra_token_info = (Map.literal[ ("QRcode", 0x6269c0f1a821); ] : (string, bytes) map) in
        let extra_token_metadata = (Big_map.literal [ (extra_token_id, extra_token_info); ] : (nat, (string, bytes) map) big_map) in

        // call MINT
        let () = Test.set_source alice in
        let taddr1 = (Test.cast_address address1 : (Factory.NFT_FA2.parameter, ext_fa2_storage) typed_address) in
        let fa2_1 : Factory.NFT_FA2.parameter contract = Test.to_contract taddr1 in
        let mint_args : Factory.NFT_FA2.mint_param = { ids=extra_token_ids; metas=extra_token_metadata } in
        let _ = Test.transfer_to_contract_exn fa2_1 (Mint(mint_args)) 0mutez in

        // verify token2 is created and owned by alice
        //let () = Test.log("check new token 2") in
        let fa2_1_s : ext_fa2_storage = Test.get_storage taddr1 in
        let () = assert(Factory.NFT_FA2.Storage.is_owner_of fa2_1_s alice 2n) in
        "OK"
    in
    let _mint_token3_collection_1_should_fail = 
        let () = Test.log("_mint_token3_collection_1_should_fail") in

        let x : Factory.parameter contract = Test.to_contract addr in

        // Retrieve address of collection 1
        let s_before : Factory.storage = Test.get_storage addr in
        let colls_before : address list = match Big_map.find_opt alice s_before.owned_collections with
        | None -> ([] : address list)
        | Some oc -> oc
        in
        //let colls_before_list : address list = Set.fold (fun(acc, i : address list * address) -> i :: acc) colls_before ([] : address list) in
        let address1 : address = Option.unopt (List.head_opt colls_before) in

        // prepare mint arguments
        //let () = Test.log("alice mint token 3 in collection 1") in
        let extra_token_id : nat = 3n in
        let extra_token_qrcode : bytes = 0x92a77bf1a4c5 in
        let extra_token_ids : nat list = [extra_token_id] in
        let extra_token_info = (Map.literal[ ("QRcode", extra_token_qrcode); ("author", Bytes.pack frank); ] : (string, bytes) map) in
        let extra_token_metadata = (Big_map.literal [ (extra_token_id, extra_token_info); ] : (nat, (string, bytes) map) big_map) in

        // call MINT
        let () = Test.set_source bob in
        let taddr1 = (Test.cast_address address1 : (Factory.NFT_FA2.parameter, ext_fa2_storage) typed_address) in
        let fa2_1 : Factory.NFT_FA2.parameter contract = Test.to_contract taddr1 in
        let mint_args : Factory.NFT_FA2.mint_param = { ids=extra_token_ids; metas=extra_token_metadata } in
        let fail_mint_token3 = Test.transfer_to_contract fa2_1 (Mint(mint_args)) 0mutez in 
        assert_string_failure fail_mint_token3 Factory.NFT_FA2.Errors.only_admin
    in
    let _generates_collection_2_with_5_tokens_should_works = 
        let () = Test.log("_generates_collection_2_with_5_tokens_should_works") in
        // check existing collections
        let s_before : Factory.storage = Test.get_storage addr in
        let colls_before : address list = match Big_map.find_opt alice s_before.owned_collections with
        | None -> ([] : address list)
        | Some x -> x
        in
        //let colls_before_list : address list = Set.fold (fun(acc, i : address list * address) -> i :: acc) colls_before ([] : address list) in
        let address1 : address = Option.unopt (List.head_opt colls_before) in

        let x : Factory.parameter contract = Test.to_contract addr in

        //let () = Test.log("alice generates a collection 2") in
        let () = Test.set_source alice in
 
        // set new collection 2
        let token_ids : nat list = [1n; 2n; 3n ;4n; 5n] in

        // add specific metadata for each token
        let token_info_1 = (Map.literal[ ("QRcode", 0x623d82eff132); ("author", Bytes.pack frank); ] : (string, bytes) map) in
        let token_info_2 = (Map.literal[ ("QRcode", 0x49aa82eff132); ("author", Bytes.pack frank); ] : (string, bytes) map) in
        let token_info_3 = (Map.literal[ ("QRcode", 0xab3442eff132); ("author", Bytes.pack frank); ] : (string, bytes) map) in
        let token_info_4 = (Map.literal[ ("QRcode", 0xdeadbeefdead); ("author", Bytes.pack frank); ] : (string, bytes) map) in
        let token_info_5 = (Map.literal[ ("QRcode", 0xdeadbeefbeef); ("author", Bytes.pack frank); ] : (string, bytes) map) in

        let token_metadata = (Big_map.literal [
            (1n, ({token_id=1n;token_info=token_info_1;} : Factory.NFT_FA2.NFT.TokenMetadata.data));
            (2n, ({token_id=2n;token_info=token_info_2;} : Factory.NFT_FA2.NFT.TokenMetadata.data));
            (3n, ({token_id=3n;token_info=token_info_3;} : Factory.NFT_FA2.NFT.TokenMetadata.data));
            (4n, ({token_id=4n;token_info=token_info_4;} : Factory.NFT_FA2.NFT.TokenMetadata.data));
            (5n, ({token_id=5n;token_info=token_info_5;} : Factory.NFT_FA2.NFT.TokenMetadata.data));
        ] : Factory.NFT_FA2.NFT.TokenMetadata.t) in

        // add global metadatas to all tokens
        let collection_name_bytes : bytes = Bytes.pack "Pietrus 2022" in
        let global_metadatas : (string, bytes) map = (Map.literal[ ("collection", collection_name_bytes)] : (string, bytes) map) in 
        let new_token_metadata = Factory.NFT_FA2.NFT.TokenMetadata.add_global_metadata token_ids token_metadata global_metadatas in

        // generate collection
        let gencol_args : Factory.Parameter.generate_collection_param = {name="alice_collection_1"; token_ids=token_ids; token_metas=new_token_metadata} in
        let _ = Test.transfer_to_contract_exn x (GenerateCollection(gencol_args)) 1000000mutez in

        let s : Factory.storage = Test.get_storage addr in
        // verify number of collections
        let colls : address list = match Big_map.find_opt alice s.owned_collections with
        | None -> ([] : address list)
        | Some x -> x
        in
        //let owned_coll_size : nat = Set.size colls in 
        let owned_coll_size = List.fold (fun(acc, elt : nat * address) : nat -> acc + 1n) colls 0n in
        let () = assert (owned_coll_size = 2n) in

        let parse_metas(acc, elt : (address, (nat list * Factory.NFT_FA2.NFT.TokenMetadata.t))big_map * address) : (address, (nat list * Factory.NFT_FA2.NFT.TokenMetadata.t))big_map = 
            let taddr = (Test.cast_address elt : (Factory.NFT_FA2.parameter, ext_fa2_storage) typed_address) in
            let fa2_store : ext_fa2_storage = Test.get_storage taddr in
            Big_map.add elt (fa2_store.token_ids, fa2_store.token_metadata) acc
        in
        let all_tokens : (address, (nat list * Factory.NFT_FA2.NFT.TokenMetadata.t))big_map = List.fold parse_metas colls (Big_map.empty : (address, (nat list * Factory.NFT_FA2.NFT.TokenMetadata.t) )big_map) in 
        
        // Retrieve collection 2 address
        //let colls_list : address list = Set.fold (fun(acc, i : address list * address) -> i :: acc) colls ([] : address list) in
        // find address of collection 2
        let get_next_address(lst, blacklist : address list * address list) : address =
            let filter(acc, elt : (address list * address list) * address) : (address list * address list) = 
                let is_in_list(res, i : (bool * address) * address) : (bool * address) = if res.0 then res else (i = res.1, res.1) in
                let is_blacklisted, _ = List.fold is_in_list acc.1 (false, elt) in
                if is_blacklisted then acc else (elt :: acc.0, acc.1) 
            in
            let filtered_list, _ = List.fold filter lst (([] : address list), blacklist) in
            Option.unopt (List.head_opt filtered_list) 
        in
        let address2 : address = get_next_address(colls, colls_before) in

        // verify token_ids of collection 1
        let collection1_info : nat list * Factory.NFT_FA2.NFT.TokenMetadata.t = match Big_map.find_opt address1 all_tokens with
        | None -> (failwith("No metadata for collection 1") : nat list * Factory.NFT_FA2.NFT.TokenMetadata.t)
        | Some info -> info
        in
        //let () = Test.log(collection1_info.0) in
        let () = assert(collection1_info.0 = [2n; 1n]) in
        // verify token_ids of collection 2 
        let collection2_info : nat list * Factory.NFT_FA2.NFT.TokenMetadata.t = match Big_map.find_opt address2 all_tokens with
        | None -> (failwith("No metadata for collection 2") : nat list * Factory.NFT_FA2.NFT.TokenMetadata.t)
        | Some info -> info
        in
        let () = assert(collection2_info.0 = [1n; 2n; 3n; 4n; 5n]) in 
        // verify metadata of token 3 of collection 2
        let collection2_metas : Factory.NFT_FA2.NFT.TokenMetadata.t = collection2_info.1 in
        let collection2_metas_tok3 : Factory.NFT_FA2.NFT.TokenMetadata.data = match Big_map.find_opt 3n collection2_metas with
        | None -> (failwith("No token 3 in this collection") : Factory.NFT_FA2.NFT.TokenMetadata.data)
        | Some info -> info
        in
        let () = assert(collection2_metas_tok3.token_info = (Map.literal[ ("QRcode", 0xab3442eff132); ("author", Bytes.pack frank); ("collection", collection_name_bytes)] : (string, bytes) map)) in
        // verify metadata of token 4 of collection 2
        let collection2_metas_tok4 : Factory.NFT_FA2.NFT.TokenMetadata.data = match Big_map.find_opt 4n collection2_metas with
        | None -> (failwith("No token 4 in this collection") : Factory.NFT_FA2.NFT.TokenMetadata.data)
        | Some info -> info
        in
        let () = assert(collection2_metas_tok4.token_info = (Map.literal[ ("QRcode", 0xdeadbeefdead); ("author", Bytes.pack frank); ("collection", collection_name_bytes)] : (string, bytes) map)) in
        "OK" 
    in
    let _transfer_token1_collection_2_should_works = 
        let () = Test.log("_transfer_token1_collection_2_should_works") in
        // retrieve address collection 2
        let s_before : Factory.storage = Test.get_storage addr in
        let colls_before : address list = match Big_map.find_opt alice s_before.owned_collections with
        | None -> ([] : address list)
        | Some x -> x
        in
        let address2 : address = Option.unopt (List.head_opt colls_before) in

        let () = Test.log("alice transfer tok 1 to bob") in 
        let () = Test.set_source alice in
        let taddr2 = (Test.cast_address address2 : (Factory.NFT_FA2.parameter, ext_fa2_storage) typed_address) in
        let fa2_2 : Factory.NFT_FA2.parameter contract = Test.to_contract taddr2 in
        let fa2_2_storage : ext_fa2_storage = Test.get_storage taddr2 in
        let fa2_royalties : tez = fa2_2_storage.extension.royalties in 
        let transfer1_args : Factory.NFT_FA2.NFT.transfer = [{ from_=alice; tx=[{to_=bob;token_id=1n}] }] in
        let _ = Test.transfer_to_contract_exn fa2_2 (Transfer(transfer1_args)) fa2_royalties in

        let fa2_2_s : ext_fa2_storage = Test.get_storage taddr2 in
        let () = assert(Factory.NFT_FA2.Storage.is_owner_of fa2_2_s bob 1n) in
        let () = assert(Factory.NFT_FA2.Storage.is_owner_of fa2_2_s alice 2n) in 
        let () = assert(Factory.NFT_FA2.Storage.is_owner_of fa2_2_s alice 3n) in
        let () = assert(Factory.NFT_FA2.Storage.is_owner_of fa2_2_s alice 4n) in
        let () = assert(Factory.NFT_FA2.Storage.is_owner_of fa2_2_s alice 5n) in

        let () = Test.log("bob transfer tok 1 to steven") in 
        let frank_balance_of_before = Test.get_balance frank in  
        let () = Test.set_source bob in
        let fa2_2 : Factory.NFT_FA2.parameter contract = Test.to_contract taddr2 in
        let transfer1_args : Factory.NFT_FA2.NFT.transfer = [{ from_=bob; tx=[{to_=steven;token_id=1n}] }] in
        let _ = Test.transfer_to_contract_exn fa2_2 (Transfer(transfer1_args)) fa2_royalties in

        let fa2_2_s : ext_fa2_storage = Test.get_storage taddr2 in
        let () = assert(Factory.NFT_FA2.Storage.is_owner_of fa2_2_s steven 1n) in
        let frank_balance_of_after = Test.get_balance frank in
        let amount_transfered_to_author_opt : tez option = frank_balance_of_after - frank_balance_of_before in
        let amount_transfered_to_author : tez = Option.unopt(amount_transfered_to_author_opt) in
        let () = assert(amount_transfered_to_author = 1mutez) in
        "OK" 
    in
    ()