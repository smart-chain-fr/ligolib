#include "payment_types.mligo"
#include "payment_errors.mligo"

let addCurrency(param, store : (currency * address) * paymentStorage) : returnPayment = 
    let _check_if_admin : unit = assert_with_error (Tezos.sender = store.admin) only_admin in
    let new_key : address option = Map.find_opt param.0 store.currencies in
    let new_currencies : (currency, address) map = match new_key with
    | Some (_cur) -> (failwith(currency_already_exist) : (currency, address) map)
    | None -> Map.add param.0 param.1 store.currencies
    in
    (([] : operation list), { store with currencies = new_currencies })

let deleteCurrency(param, store : currency * paymentStorage) : returnPayment = 
    let _check_if_admin : unit = assert_with_error (Tezos.sender = store.admin) only_admin in
    let rem_key : address option = Map.find_opt param store.currencies in
    let new_currencies : (currency, address) map = match rem_key with
    | None -> (failwith(currency_unknown) : (currency, address) map)
    | Some (_cc) -> Map.update param (None : address option) store.currencies
    in
    (([] : operation list), { store with currencies = new_currencies })

let setAdmin(param, store : address * paymentStorage) : returnPayment =
    let _check_if_admin : unit = assert_with_error (Tezos.sender = store.admin) only_admin in
    (([] : operation list), { store with admin = param })

let associateEscrowToPayment(param, store : (escrowId * address) * paymentStorage) : returnPayment = 
    let existingEscrowOpt : escrow option = Map.find_opt param.0 store.escrows in
    let new_escrows : (escrowId, escrow) big_map = match existingEscrowOpt with
    | Some (esc) -> Big_map.update param.0 (Some({ esc with escrowContract=Some(param.1)})) store.escrows 
    | None -> (failwith(escrow_unknown) : (escrowId, escrow) big_map)
    in
    (([] : operation list), { store with escrows = new_escrows })

let createPay(param, store : createPayParameter * paymentStorage) : returnPayment =
    let existingEscrowOpt : escrow option = Map.find_opt param.escrowId store.escrows in
    let new_escrows : (escrowId, escrow) big_map = match existingEscrowOpt with
    | Some (_esc) -> (failwith(escrow_already_exist) : (escrowId, escrow) big_map) 
    | None -> (Big_map.add param.escrowId ({currency=param.currency; amount=param.amount; buyer=param.buyer; seller=param.seller; escrowContract=(None : address option); canceled=false; released=false; paid=false} : escrow) store.escrows : (escrowId, escrow) big_map)
    in
    (([] : operation list), { store with escrows = new_escrows })

let pay(param, store : payParameter * paymentStorage) : returnPayment =
    let _check_amount : unit = assert_with_error (Tezos.amount = 0mutez) no_tez_amount in
    let existingEscrowOpt : escrow option = Map.find_opt param.escrowId store.escrows in
    let current_escrow : escrow = match existingEscrowOpt with
    | None -> (failwith(escrow_unknown) : escrow) 
    | Some (esc) -> esc
    in
    let _check_if_canceled : unit = assert_with_error (current_escrow.canceled = false) escrow_canceled in
    let _check_if_released : unit = assert_with_error (current_escrow.released = false) escrow_released in
    let _check_if_paid : unit = assert_with_error (current_escrow.paid = false) escrow_paid in
    // buyer sequestre funds
    let _check_buyer : unit = assert_with_error (current_escrow.buyer = Tezos.sender) not_buyer in
    let _check_if_currency_match : unit = assert_with_error (current_escrow.currency = param.currency) only_currency in
    let currency_address : address = match Map.find_opt param.currency store.currencies with
    | Some(ca) -> ca
    | None -> (failwith(currency_unknown) : address) 
    in
    let fa12_ci_opt: fa12_transfer contract option = Tezos.get_entrypoint_opt "%transfer" currency_address in
    let fa12_ci : fa12_transfer contract = match fa12_ci_opt with
    | Some(ca) -> ca
    | None -> (failwith(currency_no_transfer_entrypoint) : fa12_transfer contract)
    in
    let transfer_param : fa12_transfer = Tezos.sender, (Tezos.self_address, param.amount) in
    let op : operation = Tezos.transaction transfer_param 0mutez fa12_ci in
    let new_escrows : (escrowId, escrow) big_map = Big_map.update param.escrowId (Some({ current_escrow with paid=true })) store.escrows in
    ([ op; ], { store with escrows=new_escrows })

let cancelPayment(param, store : escrowId * paymentStorage) : returnPayment =
    let _check_if_admin : unit = assert_with_error (Tezos.sender = store.admin) only_admin in
    let current_escrow : escrow = match Map.find_opt param store.escrows with
    | None -> (failwith(escrow_unknown) : escrow) 
    | Some (esc) -> esc
    in
    let _check_if_canceled : unit = assert_with_error (current_escrow.canceled = false) escrow_canceled in
    let _check_if_released : unit = assert_with_error (current_escrow.released = false) escrow_released in
    let _check_if_paid : unit = assert_with_error (current_escrow.paid = true) escrow_not_paid in
    // pay back to buyer
    let currency_address : address = match Map.find_opt current_escrow.currency store.currencies with
    | Some(ca) -> ca
    | None -> (failwith(currency_unknown) : address) 
    in
    let fa12_ci_opt: fa12_transfer contract option = Tezos.get_entrypoint_opt "%transfer" currency_address in
    let fa12_ci : fa12_transfer contract = match fa12_ci_opt with
    | Some(ca) -> ca
    | None -> (failwith(currency_no_transfer_entrypoint) : fa12_transfer contract)
    in
    let transfer_param : fa12_transfer = Tezos.self_address, (current_escrow.buyer, current_escrow.amount) in
    let op : operation = Tezos.transaction transfer_param 0mutez fa12_ci in
    // mark this escrow as canceled
    let new_escrows : (escrowId, escrow) big_map = Big_map.update param (Some({ current_escrow with canceled=true })) store.escrows in
    ([ op; ], { store with escrows=new_escrows })
 
let releasePayment(param, store : escrowId * paymentStorage) : returnPayment =
    let current_escrow : escrow = match Map.find_opt param store.escrows with
    | None -> (failwith(escrow_unknown) : escrow) 
    | Some (esc) -> esc
    in
    let _check_if_canceled : unit = assert_with_error (current_escrow.canceled = false) escrow_canceled in
    let _check_if_released : unit = assert_with_error (current_escrow.released = false) escrow_released in
    let _check_if_paid : unit = assert_with_error (current_escrow.paid = true) escrow_not_paid in
    // pay to seller
    let currency_address : address = match Map.find_opt current_escrow.currency store.currencies with
    | Some(ca) -> ca
    | None -> (failwith(currency_unknown) : address) 
    in
    let fa12_ci_opt: fa12_transfer contract option = Tezos.get_entrypoint_opt "%transfer" currency_address in
    let fa12_ci : fa12_transfer contract = match fa12_ci_opt with
    | Some(ca) -> ca
    | None -> (failwith(currency_no_transfer_entrypoint) : fa12_transfer contract)
    in
    let transfer_param : fa12_transfer = Tezos.self_address, (current_escrow.seller, current_escrow.amount) in
    let op : operation = Tezos.transaction transfer_param 0mutez fa12_ci in
    // mark this escrow as canceled
    let new_escrows : (escrowId, escrow) big_map = Big_map.update param (Some({ current_escrow with released=true })) store.escrows in
    ([ op; ], { store with escrows=new_escrows })

let main(p, s : paymentEntrypoints * paymentStorage) : returnPayment =
    match p with
    | AddCurrency (x) -> addCurrency(x, s)
    | DeleteCurrency (x) -> deleteCurrency(x, s)
    | Pay (x) -> pay(x, s)
    | CancelPayment (x) -> cancelPayment(x, s)
    | ReleasePayment (x) -> releasePayment(x, s)
    | SetEscrowcontract (x) -> associateEscrowToPayment(x, s)
    | SetAdmin (x) -> setAdmin(x, s)
    
