#include "indice_types.mligo"
#include "indice_errors.mligo"

let increment(param, store : int * indiceStorage) : indiceFullReturn = 
    (([]: operation list), store + param)

let decrement(param, store : int * indiceStorage) : indiceFullReturn = 
    (([]: operation list), store - param)

let sendValue(_param, store : unit * indiceStorage) : indiceFullReturn = 
    let c_opt : int contract option = Tezos.get_entrypoint_opt "%receiveValue" Tezos.sender in
    let destination : int contract = match c_opt with
    | Some(c) -> c
    | None -> (failwith(missing_entrypoint_receivevalue) : int contract)
    in
    let op : operation = Tezos.transaction store 0mutez destination in
    ([ op; ], store)

let indiceMain(ep, store : indiceEntrypoints * indiceStorage) : indiceFullReturn =
    let ret : indiceFullReturn = match ep with 
    | Increment(p) -> increment(p, store)
    | Decrement(p) -> decrement(p, store)
    | SendValue(p) -> sendValue(p, store)
    in
    ret

[@view] let indice_value(_params, store: unit * indiceStorage): int option = Some(store)