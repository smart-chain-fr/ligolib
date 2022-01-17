//////////////////
//      TYPES
//////////////////
type indiceEntry = {
    contractAddress : address;
    viewName: string;
}

type advisorAlgo = ((int list) -> bool)

type advisorStorage = {
    indices : indiceEntry list;
    algorithm : advisorAlgo;
    result : bool;
}

type advisorEntrypoints = ChangeAlgorithm of advisorAlgo | ExecuteAlgorithm of unit

type advisorFullReturn = operation list * advisorStorage

//////////////////
//      ERRORS
//////////////////
let unknownView : string = "View indice_value not found"

//////////////////
//  FUNCTIONS
//////////////////
let change(p, s : advisorAlgo * advisorStorage) : advisorFullReturn = 
    (([] : operation list), { s with algorithm = p})

let executeAlgorithm(s : advisorStorage) : advisorFullReturn =
    let getValue(elt: indiceEntry) : int = 
        let vn : string = "indice_value" in 
        let indiceValOpt : int option = Tezos.call_view vn unit elt.contractAddress in
        let indiceVal : int = match indiceValOpt with
        | None -> (failwith(unknownView) : int)
        | Some (v) -> v
        in
        indiceVal
    in
    let values : int list = List.map getValue s.indices in
    (([] : operation list), { s with result = s.algorithm values })

//////////////////
//      MAIN
//////////////////
let advisorMain(ep, store : advisorEntrypoints * advisorStorage) : advisorFullReturn = 
    let ret : advisorFullReturn = match ep with
    | ChangeAlgorithm(p) -> change(p, store)
    | ExecuteAlgorithm(_p) -> executeAlgorithm(store) 
    in 
    ret
