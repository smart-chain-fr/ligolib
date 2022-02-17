type storage = bytes

type revealParam = chest_key * chest * nat

type action = Stone | Paper | Cisor

type parameter = Reveal of revealParam | Nothing of unit 

type return = operation list * storage

let reveal (pp, _s : (chest_key * chest * nat) * storage) : return =
  let (ck,c, salt) = pp in
  let new_s =
    match Tezos.open_chest ck c salt with
    | Ok_opening b -> b
    | Fail_timelock -> 0x00
    | Fail_decrypt -> 0x01
  in
  (([] : operation list), new_s)


let main (p , s : parameter * storage) : return =
  match p with
  | Nothing -> (([] : operation list), s)
  | Reveal pp -> reveal(pp, s) 


let test =
  let init_storage : bytes = 0x00 in
  let (addr,_,_) = Test.originate main init_storage 0tez in
  
  let _test1 = (* chest key/payload and time matches -> OK *)
    let payload_str : string = "toto" in
    let payload : bytes = Bytes.pack payload_str in 
    let (chest,chest_key) = Test.create_chest payload 10n in

    let x : parameter contract = Test.to_contract addr in
    let arg : parameter = Reveal(chest_key , chest, 10n) in
    let _ = Test.transfer_to_contract_exn x arg 0tez in
    let s = Test.get_storage addr in
    let () = Test.log(s) in
    let res : string = match (Bytes.unpack s : string option) with
    | None -> failwith("fail to unpac the payload")
    | Some x -> x
    in
    Test.log(res)
  in
  let _test2 = (* chest key/payload and time matches -> OK *)
    let payload_v : action = Cisor in
    let () = Test.log(payload_v) in
    let payload : bytes = Bytes.pack payload_v in 
    
    let () = Test.log(payload) in
    let (chest,chest_key) = Test.create_chest payload 10n in
    let x : parameter contract = Test.to_contract addr in
    let arg : parameter = Reveal(chest_key , chest, 10n) in
    let _ = Test.transfer_to_contract_exn x arg 0tez in
    let s = Test.get_storage addr in
    let () = Test.log(s) in
    let res : action = match (Bytes.unpack s : action option) with
    | None -> failwith("fail to unpack the payload")
    | Some x -> x
    in
    Test.log(res)
  in
  ()

