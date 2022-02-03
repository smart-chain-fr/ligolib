module Storage = struct
    type t = int
end

module Parameter = struct
    type t = Increment of int | Decrement of int
end

type storage = Storage.t
type parameter = Parameter.t
type return = operation list * storage

let increment(param, store : int * storage) : return = 
    (([]: operation list), store + param)

let decrement(param, store : int * storage) : return = 
    (([]: operation list), store - param)

let indiceMain(ep, store : parameter * storage) : return =
    match ep with 
    | Increment(p) -> increment(p, store)
    | Decrement(p) -> decrement(p, store)

[@view] let indice_value(_params, store: unit * storage): int = store