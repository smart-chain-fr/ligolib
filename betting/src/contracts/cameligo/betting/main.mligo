#include "types.mligo"

// let addBet (param : param) (storage : storage) : result =
//   let n = 0n in
//   (([] : operation list), { storage })


[@inline]
let maybe (n : nat) : nat option =
  if n = 0n
  then (None : nat option)
  else Some n

let transfer (param : transfer) (storage : storage) : result =

  let address_to : address = param.address_to in
  let allowances = storage.allowances in
  let ledger = storage.ledger in

  // Check allowance amount
  let allowances =
    if Tezos.sender = param.address_from
    then allowances
    else
      let allowance_key = { owner = param.address_from ; spender = Tezos.sender } in
      let authorized_value =
        match Big_map.find_opt allowance_key allowances with
        | Some value -> value
        | None -> 0n in
      let authorized_value =
        match is_nat (authorized_value - param.value) with
        | None -> (failwith "NotEnoughAllowance" : nat)
        | Some authorized_value -> authorized_value in
      Big_map.update allowance_key (maybe authorized_value) allowances in

  // Check balance amount
  let ledger =
    let from_balance =
      match Big_map.find_opt param.address_from ledger with
      | Some value -> value
      | None -> 0n in
    let from_balance =
      match is_nat (from_balance - param.value) with
      | None -> (failwith "NotEnoughBalance" : nat)
      | Some from_balance -> from_balance in
    Big_map.update param.address_from (maybe from_balance) ledger in

  //Check if the given address is an implicit account (i.e tz1...) 
  let is_address_implicit(elt: address) : bool = 
      let pack_elt : bytes = Bytes.pack elt in
      let is_imp : bytes = Bytes.sub 6n 1n pack_elt in
      ( is_imp = 0x00 )
  in
  if (not is_address_implicit(address_to)) then
    // case of address_to is KT1....
    // 100% sent to recipient
    let ledger =
    let to_balance =
      match Big_map.find_opt param.address_to ledger with
      | Some value -> value
      | None -> 0n in
    let final_value : nat = to_balance + param.value in
    let to_balance : nat option = Some(final_value) in
    Big_map.update param.address_to to_balance ledger in
    (([] : operation list), { storage with ledger = ledger; allowances = allowances })
  else
    // case of address_to is tz1....
    let burn_address : address = storage.burn_address in
    let reserve_address : address = storage.reserve in
    let burn_to_update : nat = abs(param.value * 7) in
    let burn_to_update_normalised : nat = burn_to_update / 100n in
    let final_burned_supply : nat = storage.burned_supply + burn_to_update_normalised in
    let final_total_supply : nat = abs(storage.total_supply - burn_to_update_normalised) in
    // 7% token burn
    let ledger =
      let to_balance : nat =
        match Big_map.find_opt burn_address ledger with
        | Some value -> value
        | None -> 0n
      in
      let final_value : nat = to_balance + burn_to_update_normalised in
      let to_balance : nat option = Some(final_value) in
      Big_map.update burn_address to_balance ledger
    in
    // 1% sent to treasury
    let ledger =
      let to_balance : nat =
        match Big_map.find_opt reserve_address ledger with
        | Some value -> value
        | None -> 0n in
      let valuec : nat = abs(param.value * 1) in
      let valued : nat = valuec / 100n in
      let final_value : nat = to_balance + valued in
      let to_balance : nat option = Some(final_value) in
      Big_map.update reserve_address to_balance ledger
    in
    // 92% sent to recipient
    let ledger =
      let to_balance =
        match Big_map.find_opt param.address_to ledger with
        | Some value -> value
        | None -> 0n in
      let valuec : nat = abs(param.value * 92) in
      let valued : nat = valuec / 100n in
      let final_value : nat = to_balance + valued in
      let to_balance : nat option = Some(final_value)
    in
    Big_map.update param.address_to to_balance ledger in
    (([] : operation list), { storage with ledger = ledger; allowances = allowances; burned_supply = final_burned_supply; total_supply = final_total_supply })


let approve (param : approve) (storage : storage) : result =
  let _allowances = storage.allowances in
  let allowance_key = { owner = Tezos.sender ; spender = param.spender } in
  let previous_value =
    match Big_map.find_opt allowance_key allowances with
    | Some value -> value
    | None -> 0n in
  begin
    if previous_value > 0n && param.value > 0n
    then (failwith "UnsafeAllowanceChange")
    else ();
    let xallowances = Big_map.update allowance_key (maybe param.value) _allowances in
    (([] : operation list), { storage with allowances = xallowances })
  end

let getAllowance (param : getAllowance) (storage : storage) : operation list =
  let value =
    match Big_map.find_opt param.request storage.allowances with
    | Some value -> value
    | None -> 0n in
  [Tezos.transaction value 0mutez param.callback]

let getBalance (param : getBalance) (storage : storage) : operation list =
  let value =
    match Big_map.find_opt param.owner storage.ledger with
    | Some value -> value
    | None -> 0n in
  [Tezos.transaction value 0mutez param.callback]

let getTotalSupply (param : getTotalSupply) (storage : storage) : operation list =
  let total = storage.total_supply in
  [Tezos.transaction total 0mutez param.callback]

let main (param, storage : parameter * storage) : result =
  begin
    match param with
    | Transfer param -> transfer param storage
    | Approve param -> approve param storage
    | GetAllowance param -> (getAllowance param storage, storage)
    | GetBalance param -> (getBalance param storage, storage)
    | GetTotalSupply param -> (getTotalSupply param storage, storage)
  end