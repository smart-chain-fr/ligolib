type storage = bool

type parameter = Exec of (int list) | Nothing

let func(l : int list) : operation list * storage =
    let ret : bool = match List.head_opt l with
    | None -> (failwith("missing value") : bool)
    | Some (v) -> if v < 10 then True else False
    in
    (([]: operation list), ret)

let main(p, s : parameter * storage) : operation list * storage =
    let ret : operation list * storage = match p with
    | Exec (l) -> func(l)
    | Nothing -> (([]: operation list), s)
    in ret