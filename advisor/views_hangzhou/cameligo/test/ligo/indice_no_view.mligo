type indiceStorage = int

type indiceEntrypoints = Increment of int | Decrement of int

type indiceFullReturn = operation list * indiceStorage

let increment(param, store : int * indiceStorage) : indiceFullReturn = 
    (([]: operation list), store + param)

let decrement(param, store : int * indiceStorage) : indiceFullReturn = 
    (([]: operation list), store - param)

let indiceMain(ep, store : indiceEntrypoints * indiceStorage) : indiceFullReturn =
    match ep with 
    | Increment(p) -> increment(p, store)
    | Decrement(p) -> decrement(p, store)
    