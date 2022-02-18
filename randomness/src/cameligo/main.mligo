
type storage = {
    participants : address set;
    secrets : (address, chest) map;
    decoded_payloads: (address, bytes) map;
    result : bytes option
}

type commit_param = {
    secret_action : chest
}

type reveal_param = chest_key * chest * nat

type parameter = Commit of commit_param | Reveal of reveal_param 

type return = operation list * storage

// Once everybody has commit & reveal we compute some bytes as result
let trigger(payloads : (address, bytes) map) : bytes option =
    let hash_payload = fun(acc, elt: bytes list * (address * bytes)) : bytes list -> (Crypto.keccak elt.1) :: acc in
    let pl : bytes list = Map.fold hash_payload payloads ([]:bytes list) in
    let hashthemall = fun(acc, elt: bytes option * bytes) : bytes option -> 
        match acc with 
        | None -> Some(elt)
        | Some pred -> Some(Crypto.keccak (Bytes.concat elt pred)) 
    in
    List.fold hashthemall pl (None : bytes option)

// Sender commits its chest
let commit(p, st : commit_param * storage) : return =
    let _check_authorized : unit = assert_with_error (Set.mem Tezos.sender st.participants) "Not authorized" in
    let new_secrets = match Map.find_opt Tezos.sender st.secrets with
    | None -> Map.add Tezos.sender p.secret_action st.secrets
    | Some x -> (failwith("Sender has already given its chest") : (address, chest) map)
    in
    (([] : operation list), { st with secrets=new_secrets })
    
// Sender reveals its chest content
let reveal(p, s : reveal_param * storage) : return =
    let _check_authorized : unit = assert_with_error (Set.mem Tezos.sender s.participants) "Not authorized" in
    // check all chest has been received
    let committed = fun (acc, elt : bool * address) : bool -> match Map.find_opt elt s.secrets with
        | None -> acc && false
        | Some x -> acc && true
    in
    let _all_chests_committed = Set.fold committed s.participants true in
    let _check_all_chests : unit = assert_with_error (_all_chests_committed = true) "Missing some chest" in

    // check if chest match the chest given with commit entrypoint  
    let (ck,c, secret) = p in
    let sender_chest : chest = match Map.find_opt Tezos.sender s.secrets with
    | None -> failwith("Missing some chest")
    | Some ch -> ch
    in
    // TODO  .. is it a bug ?
    //let _check_chest : unit = assert_with_error (sender_chest = c) "Chests mismatch" in
    // open chest and stores the chest content
    let decoded_payload =
        match Tezos.open_chest ck c secret with
        | Ok_opening b -> b
        | Fail_timelock -> (failwith("Could not open chest") : bytes)
        | Fail_decrypt -> (failwith("Could not open chest") : bytes)
    in
    let new_decoded_payloads = match Map.find_opt Tezos.sender s.decoded_payloads with
    | None -> Map.add Tezos.sender decoded_payload s.decoded_payloads
    | Some _elt -> (failwith("Already revealed") : (address, bytes) map)
    in 
    // check all chest has been revealed
    let revealed = fun (acc, elt : bool * address) : bool -> match Map.find_opt elt new_decoded_payloads with
        | None -> acc && false
        | Some x -> acc && true
    in
    let all_chests_revealed = Set.fold revealed s.participants true in
    if all_chests_revealed = true then
        (([] : operation list), { s with decoded_payloads=new_decoded_payloads; result=trigger(new_decoded_payloads) })  
    else
        (([] : operation list), { s with decoded_payloads=new_decoded_payloads })

let main(ep, store : parameter * storage) : return =
    match ep with 
    | Commit(p) -> commit(p, store)
    | Reveal(p) -> reveal(p, store)



let test =
    let alice: address = Test.nth_bootstrap_account 0 in
    let bob: address = Test.nth_bootstrap_account 1 in
    let init_storage : storage = { 
        participants= Set.add alice (Set.add bob (Set.empty : address set));
        secrets=(Map.empty: (address, chest) map); 
        decoded_payloads=(Map.empty: (address, bytes) map); 
        result=(None : bytes option) 
    } in
    let (addr,_,_) = Test.originate main init_storage 0tez in
    let s_init = Test.get_storage addr in
    let () = Test.log(s_init) in

    let _test_should_works = (* chest key/payload and time matches -> OK *)
    
        let payload : bytes = 0x01 in
        let time_secret : nat = 10n in 
        let (my_chest,chest_key) = Test.create_chest payload time_secret in

        let payload2 : bytes = 0x02 in
        let time_secret2 : nat = 99n in 
        let (my_chest2,chest_key2) = Test.create_chest payload2 time_secret2 in

        let () = Test.log("chests created") in

        let x : parameter contract = Test.to_contract addr in

        // alice commits
        let () = Test.log("alice commits") in
        let () = Test.set_source alice in
        let commit_args : commit_param = {secret_action=my_chest} in
        //let () = Test.log(commit_args) in
        let _ = Test.transfer_to_contract_exn x (Commit(commit_args)) 0mutez in

        // bob commits
        let () = Test.log("bob commits") in
        let () = Test.set_source bob in
        let commit_args2 : commit_param = {secret_action=my_chest} in
        //let () = Test.log(commit_args) in
        let _ = Test.transfer_to_contract_exn x (Commit(commit_args2)) 0mutez in

        // alice reveals
        let () = Test.log("alice reveals") in
        let () = Test.set_source alice in
        let reveal_args : reveal_param = (chest_key, my_chest, time_secret) in
        //let () = Test.log(reveal_args) in
        let _ = Test.transfer_to_contract_exn x (Reveal(reveal_args)) 0mutez in

        // bob reveals
        let () = Test.log("bob reveals") in
        let () = Test.set_source bob in
        let reveal_args2 : reveal_param = (chest_key2, my_chest2, time_secret2) in
        let _ = Test.transfer_to_contract_exn x (Reveal(reveal_args2)) 0mutez in
        
        let () = Test.log("check storage") in
        let s2 : storage = Test.get_storage addr in
        let () = Test.log(s2) in
        let () = assert (s2.result <> (None : bytes option)) in
        Test.log("test finished")
    in
    ()

