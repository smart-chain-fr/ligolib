#include "types.mligo"
#include "errors.mligo"

let set_admin (param, store : address * paymentStorage) : returnPayment  = 
    let _check_if_admin : unit = assert_with_error (Tezos.get_sender () = store.admin) only_admin in
    ( ([] : operation list), { store with admin = param })

let add_currency (param, store : (currency * address) * paymentStorage) : returnPayment = 
    let _check_if_admin : unit = assert_with_error (Tezos.get_sender () = store.admin) only_admin in
    let new_key : address option = Map.find_opt param.0 store.currencies in
    let new_currencies : (currency, address) map = match new_key with
    | Some (_cur) -> (failwith (currency_already_exist) : (currency, address) map)
    | None -> Map.add param.0 param.1 store.currencies
    in
    ( ([] : operation list), { store with currencies = new_currencies })

let delete_currency (param, store : currency * paymentStorage) : returnPayment = 
    let _check_if_admin : unit = assert_with_error (Tezos.get_sender () = store.admin) only_admin in
    let rem_key : address option = Map.find_opt param store.currencies in
    let new_currencies : (currency, address) map = match rem_key with
    | None -> (failwith (currency_unknown) : (currency, address) map)
    | Some (_cc) -> Map.update param (None : address option) store.currencies
    in
    ( ([] : operation list), { store with currencies = new_currencies })

let associate_escrow_to_payment (param, store : (escrow_id * address) * paymentStorage) : returnPayment = 
    let existing_escrow_opt : escrow option = Map.find_opt param.0 store.escrows in
    let new_escrow : (escrow_id, escrow) map = match existing_escrow_opt with
    | Some (esc) -> Map.update param.0 (Some ({ esc with escrowContract = Some (param.1)})) store.escrows 
    | None -> (failwith (escrow_unknown) : (escrow_id, escrow) map)
    in
    ( ([] : operation list), { store with escrows = new_escrow })

let create_pay (param, store : create_pay_parameter * paymentStorage) : returnPayment  = 
    let existing_escrow_opt : escrow option = Map.find_opt param.escrow_id store.escrows in
    let new_escrow : (escrow_id, escrow) map = match existing_escrow_opt with
    | Some (_esc) -> (failwith (escrow_already_exist) : (escrow_id, escrow) map) 
    | None -> (Map.add param.escrow_id ({currency = param.currency; amount = param.amount; buyer = param.buyer; seller = param.seller; escrowContract = (None : address option); canceled = false; released = false; paid = false} : escrow) store.escrows : (escrow_id, escrow) map)
    in
    ( ([] : operation list), { store with escrows = new_escrow })

let pay_xtz (param, store : payParameter * paymentStorage) : returnPayment  = 
    let tez_amount_in_nat : nat = Tezos.get_amount () / 1mutez in
    let _check_amount : unit = assert_with_error (tez_amount_in_nat = param.amount) tez_insufficient in
    let current_escrow : escrow = match Map.find_opt param.escrow_id store.escrows with
    | None -> (failwith (escrow_unknown) : escrow) 
    | Some (esc) -> esc
    in
    let _check_escrow_amount : unit = assert_with_error (tez_amount_in_nat = current_escrow.amount) tez_insufficient in
    let _check_currency : unit = assert_with_error (current_escrow.currency = "XTZ") escrow_xtz_currency in
    let new_escrow : (escrow_id, escrow) map = Map.update param.escrow_id (Some ({ current_escrow with paid = true })) store.escrows in
    ( ([] : operation list), { store with escrows = new_escrow })

let pay_fa12 (param, store : payParameter * paymentStorage) : returnPayment  = 
    let _check_amount : unit = assert_with_error (Tezos.get_amount () = 0mutez) no_tez_amount in
    let existing_escrow_opt : escrow option = Map.find_opt param.escrow_id store.escrows in
    let current_escrow : escrow = match existing_escrow_opt with
    | None -> (failwith (escrow_unknown) : escrow) 
    | Some (esc) -> esc
    in
    let _check_if_canceled : unit = assert_with_error (current_escrow.canceled = false) escrow_canceled in
    let _check_if_released : unit = assert_with_error (current_escrow.released = false) escrow_released in
    let _check_if_paid : unit = assert_with_error (current_escrow.paid = false) escrow_paid in
    // buyer sequestre funds
    let _check_buyer : unit = assert_with_error (current_escrow.buyer = Tezos.get_sender ()) not_buyer in
    let _check_if_currency_match : unit = assert_with_error (current_escrow.currency = param.currency) only_currency in
    let currency_address : address = match Map.find_opt param.currency store.currencies with
    | Some (ca) -> ca
    | None -> (failwith (currency_unknown) : address) 
    in
    let fa12_ci_opt : fa12_transfer contract option = Tezos.get_entrypoint_opt "%transfer" currency_address in
    let fa12_ci : fa12_transfer contract = match fa12_ci_opt with
    | Some (ca) -> ca
    | None -> (failwith (currency_no_transfer_entrypoint) : fa12_transfer contract)
    in
    let transfer_param : fa12_transfer = Tezos.get_sender (), (Tezos.get_self_address (), param.amount) in
    let op : operation = Tezos.transaction transfer_param 0mutez fa12_ci in
    let new_escrow : (escrow_id, escrow) map = Map.update param.escrow_id (Some ({ current_escrow with paid = true })) store.escrows in
    ([ op; ], { store with escrows = new_escrow })

let cancel_payment (param, store : escrow_id * paymentStorage) : returnPayment  = 
    let _check_if_admin : unit = assert_with_error (Tezos.get_sender () = store.admin) only_admin in
    let current_escrow : escrow = match Map.find_opt param store.escrows with
    | None -> (failwith (escrow_unknown) : escrow) 
    | Some (esc) -> esc
    in
    let _check_if_canceled : unit = assert_with_error (current_escrow.canceled = false) escrow_canceled in
    let _check_if_released : unit = assert_with_error (current_escrow.released = false) escrow_released in
    let _check_if_paid : unit = assert_with_error (current_escrow.paid = true) escrow_not_paid in
    // pay back to buyer
    let currency_address : address = match Map.find_opt current_escrow.currency store.currencies with
    | Some (ca) -> ca
    | None -> (failwith (currency_unknown) : address) 
    in
    let fa12_ci_opt : fa12_transfer contract option = Tezos.get_entrypoint_opt "%transfer" currency_address in
    let fa12_ci : fa12_transfer contract = match fa12_ci_opt with
    | Some (ca) -> ca
    | None -> (failwith (currency_no_transfer_entrypoint) : fa12_transfer contract)
    in
    let transfer_param : fa12_transfer = Tezos.get_self_address (), (current_escrow.buyer, current_escrow.amount) in
    let op : operation = Tezos.transaction transfer_param 0mutez fa12_ci in
    // mark this escrow as canceled
    let new_escrow : (escrow_id, escrow) map = Map.update param (Some ({ current_escrow with canceled = true })) store.escrows in
    ([ op; ], { store with escrows = new_escrow })

let release_payment (param, store : escrow_id * paymentStorage) : returnPayment  = 
    let current_escrow : escrow = match Map.find_opt param store.escrows with
    | None -> (failwith (escrow_unknown) : escrow) 
    | Some (esc) -> esc
    in
    let _check_if_canceled : unit = assert_with_error (current_escrow.canceled = false) escrow_canceled in
    let _check_if_released : unit = assert_with_error (current_escrow.released = false) escrow_released in
    let _check_if_paid : unit = assert_with_error (current_escrow.paid = true) escrow_not_paid in
    // pay to seller
    let currency_address : address = match Map.find_opt current_escrow.currency store.currencies with
    | Some (ca) -> ca
    | None -> (failwith (currency_unknown) : address) 
    in
    let fa12_ci_opt : fa12_transfer contract option = Tezos.get_entrypoint_opt "%transfer" currency_address in
    let fa12_ci : fa12_transfer contract = match fa12_ci_opt with
    | Some (ca) -> ca
    | None -> (failwith (currency_no_transfer_entrypoint) : fa12_transfer contract)
    in
    let transfer_param : fa12_transfer = Tezos.get_self_address (), (current_escrow.seller, current_escrow.amount) in
    let op : operation = Tezos.transaction transfer_param 0mutez fa12_ci in
    // mark this escrow as canceled
    let new_escrow : (escrow_id, escrow) map = Map.update param (Some ({ current_escrow with released = true })) store.escrows in
    ([ op; ], { store with escrows = new_escrow })

let pay (param, store : payParameter * paymentStorage) : returnPayment  = 
    if Tezos.get_amount () = 0mutez then
        pay_fa12 (param, store)
    else
        pay_xtz (param, store)

let cancel_payment_xtz (_param, _store : escrow_id * paymentStorage) : returnPayment  = 
    (failwith ("cancel_payment_xtz not implemented") : returnPayment)

let release_payment_xtz (_param, _store : escrow_id * paymentStorage) : returnPayment  = 
    (failwith ("release_payment_xtz not implemented") : returnPayment)

let main (p, s : paymentEntrypoints * paymentStorage) : returnPayment  = 
    match p with
    | AddCurrency (x) -> add_currency (x, s)
    | DeleteCurrency (x) -> delete_currency (x, s)
    | Pay (x) -> pay (x, s)
    | CancelPayment (x) -> cancel_payment (x, s)
    | ReleasePayment (x) -> release_payment (x, s)
    | SetEscrowContract (x) -> associate_escrow_to_payment (x, s)
    | SetAdmin (x) -> set_admin (x, s)