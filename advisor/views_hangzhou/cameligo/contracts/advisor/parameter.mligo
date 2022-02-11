#import "algo.mligo" "Algo"

module Types = struct
    type t = ChangeAlgorithm of Algo.Types.t | ExecuteAlgorithm of unit
end 