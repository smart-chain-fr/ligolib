
type storage = {
    values: (address, bytes) map;
    result : address option
}

type commit_param = {
    payload : bytes;
    secret : nat
}

type reveal_param = chest_key * chest * nat

type parameter = Commit of commit_param | Reveal of reveal_param 

type return = operation list * storage


let commit(_p, st : commit_param * storage) : return =
    //let (chest, _chest_key) = Test.create_chest p.payload p.secret in
    //let new_chests = chest :: st.chests in
    //(([] : operation list), { st with chests=new_chests })
    (([] : operation list), st)

let reveal(p, s : reveal_param * storage) : return =
    let (ck,c, secret) = p in
    let decoded_payload =
        match Tezos.open_chest ck c secret with
        | Ok_opening b -> b
        | Fail_timelock -> 0x00
        | Fail_decrypt -> 0x01
    in
    let new_values = match Map.find_opt Tezos.sender s.values with
    | None -> Map.add Tezos.sender decoded_payload s.values
    | Some _elt -> (failwith("Player has already revealed its choice") : (address, bytes) map)
    in 
    (([] : operation list), { s with values=new_values })

let main(ep, store : parameter * storage) : return =
    match ep with 
    | Commit(p) -> commit(p, store)
    | Reveal(p) -> reveal(p, store)


let test =
  let init_storage : storage = { values=(Map.empty: (address, bytes) map); result=(None : address option) } in
  let (addr,_,_) = Test.originate main init_storage 0tez in
  let s_init = Test.get_storage addr in
  let () = Test.log(s_init) in

  let _test1 = (* chest key/payload and time matches -> OK *)
    
    let payload : bytes = 0x01 in
    let time_secret : nat = 10n in 
    let (my_chest,chest_key) = Test.create_chest payload time_secret in

    let payload2 : bytes = 0x02 in
    let time_secret2 : nat = 99n in 
    let (my_chest2,chest_key2) = Test.create_chest payload2 time_secret2 in

    let () = Test.log("chests created") in
    let x : parameter contract = Test.to_contract addr in
    let () = Test.log("wow1") in
    let () = Test.set_source ("tz1RyejUffjfnHzWoRp1vYyZwGnfPuHsD5F5" : address) in
    let () = Test.log("wow2") in
    let reveal_args : reveal_param = (chest_key, my_chest, time_secret) in
    //let () = Test.log(reveal_args) in
    let _ = Test.transfer_to_contract_exn x (Reveal(reveal_args)) 0mutez in
    let () = Test.log("wow3") in
    let s = Test.get_storage addr in
    let () = Test.log(s) in
    let () = Test.set_source ("tz1Tr5mdFTtGZp9p2KUuWXxJHB6HSAZBj15u" : address) in
    let () = Test.transfer_to_contract_exn x (Reveal((chest_key2, my_chest2, time_secret2))) 0mutez in
    let s2 = Test.get_storage addr in
    let () = Test.log(s2) in
    Test.log("test finished")
  in
  ()

