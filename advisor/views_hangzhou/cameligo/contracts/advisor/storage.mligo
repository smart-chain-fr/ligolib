#import "algo.mligo" "Algo"
#import "errors.mligo" "Errors"

module Types = struct
    type t = {
        indiceAddress : address;
        algorithm : Algo.Types.t;
        result : bool;
    }
end

module Utils = struct
    let change(p, s : Algo.Types.t * Types.t) : Types.t = 
        { s with algorithm = p}

    let executeAlgorithm(s : Types.t) : Types.t =
        let indiceValOpt : int option = Tezos.call_view "indice_value" unit s.indiceAddress in
        let indiceVal : int = match indiceValOpt with
        | None -> (failwith(Errors.unknownView) : int)
        | Some (v) -> v
        in
        { s with result = s.algorithm indiceVal }
end