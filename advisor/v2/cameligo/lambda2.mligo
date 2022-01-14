type storage = bool

type parameter = Exec of (int list) | Nothing

let func(l : int list) : operation list * storage =
    let _check : bool = match List.head_opt l with
    | None -> (failwith("empty list") : bool)
    | Some (_v) -> True
    in
    let (sum, size) : int * nat = List.fold (fun((acc, nb), elt : (int * nat) * int) : (int * nat) -> (acc + elt, nb + 1n)) l (0, 0n) in 
    let mean : int = sum / size in
    let ret : bool = if mean < 5 then True else False
    in
    (([]: operation list), ret)

let main(p, s : parameter * storage) : operation list * storage =
    let ret : operation list * storage = match p with
    | Exec (l) -> func(l)
    | Nothing -> (([]: operation list), s)
    in ret