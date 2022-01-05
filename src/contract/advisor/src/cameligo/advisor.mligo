#include "advisor_types.mligo"
#include "advisor_errors.mligo"

let request(_p, s : unit * advisorStorage) : advisorFullReturn = 
    let c_opt : unit contract option = Tezos.get_entrypoint_opt "%sendValue" s.indiceAddress in
    let destination : unit contract = match c_opt with
    | Some(c) -> c
    | None -> (failwith(missing_entrypoint_sendvalue) : unit contract)
    in
    let op : operation = Tezos.transaction unit 0mutez destination in
    ([ op; ], s)

let execute(indiceVal, s : int * advisorStorage) : advisorFullReturn =
    (([] : operation list), { s with result = s.algorithm indiceVal })


let change(p, s : advisorAlgo * advisorStorage) : advisorFullReturn = 
    (([] : operation list), { s with algorithm = p})

let advisorMain(ep, store : advisorEntrypoints * advisorStorage) : advisorFullReturn = 
    let ret : advisorFullReturn = match ep with
    | ReceiveValue(p) -> execute(p, store)
    | RequestValue(p) -> request(p, store)
    | ChangeAlgorithm(p) -> change(p, store)
    in 
    ret