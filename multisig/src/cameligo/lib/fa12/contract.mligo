#import "parameter.mligo" "Parameter"
#import "storage.mligo" "Storage"

type result = operation list * Storage.Types.t

[@inline]
let positive (n : nat) : nat option =
  if n = 0n
  then (None : nat option)
  else Some n

let transfer (param, storage : Parameter.Types.transfer * Storage.Types.t) : result =
  let allowances = storage.allowances in
  let tokens = storage.tokens in
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
      Big_map.update allowance_key (positive authorized_value) allowances in
  let tokens =
    let from_balance =
      match Big_map.find_opt param.address_from tokens with
      | Some value -> value
      | None -> 0n in
    let from_balance =
      match is_nat (from_balance - param.value) with
      | None -> (failwith "NotEnoughBalance" : nat)
      | Some from_balance -> from_balance in
    Big_map.update param.address_from (positive from_balance) tokens in
  let tokens =
    let to_balance =
      match Big_map.find_opt param.address_to tokens with
      | Some value -> value
      | None -> 0n in
    let to_balance = to_balance + param.value in
    Big_map.update param.address_to (positive to_balance) tokens in
  (([] : operation list), { storage with tokens = tokens; allowances = allowances })

let approve (param, storage : Parameter.Types.approve * Storage.Types.t) : result =
  let allowances = storage.allowances in
  let allowance_key = { owner = Tezos.sender ; spender = param.spender } in
  let previous_value =
    match Big_map.find_opt allowance_key allowances with
    | Some value -> value
    | None -> 0n in
  begin
    if previous_value > 0n && param.value > 0n
    then (failwith "UnsafeAllowanceChange")
    else ();
    let allowances = Big_map.update allowance_key (positive param.value) allowances in
    (([] : operation list), { storage with allowances = allowances })
  end

let getAllowance (param, storage : Parameter.Types.getAllowance * Storage.Types.t) : operation list =
  let value =
    match Big_map.find_opt param.request storage.allowances with
    | Some value -> value
    | None -> 0n in
  [Tezos.transaction value 0mutez param.callback]

let getBalance (param, storage : Parameter.Types.getBalance * Storage.Types.t) : operation list =
  let value =
    match Big_map.find_opt param.owner storage.tokens with
    | Some value -> value
    | None -> 0n in
  [Tezos.transaction value 0mutez param.callback]

let getTotalSupply (param, storage : Parameter.Types.getTotalSupply * Storage.Types.t) : operation list =
  let total = storage.total_supply in
  [Tezos.transaction total 0mutez param.callback]

let main (param, storage : Parameter.Types.t * Storage.Types.t) : result =
  begin
    if Tezos.amount <> 0mutez
    then failwith "DontSendTez"
    else ();
    match param with
    | Transfer param -> transfer (param, storage)
    | Approve param -> approve (param, storage)
    | GetAllowance param -> (getAllowance (param, storage), storage)
    | GetBalance param -> (getBalance (param, storage), storage)
    | GetTotalSupply param -> (getTotalSupply (param, storage), storage)
  end

// Mocked view returning always 42 
[@view] let superview ((),_ : unit * Storage.Types.t) : int = 42