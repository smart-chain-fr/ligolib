type advisorAlgo = (int -> bool)

type advisorStorage = {
    indiceAddress : address;
    algorithm : advisorAlgo;
    result : bool;
}

type advisorEntrypoints = ReceiveValue of int | RequestValue of unit | ChangeAlgorithm of advisorAlgo

type advisorFullReturn = operation list * advisorStorage