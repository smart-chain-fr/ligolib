type advisorAlgo = (int -> bool)

type advisorStorage = {
    indiceAddress : address;
    algorithm : advisorAlgo;
    result : bool;
}

type advisorEntrypoints = ReceiveValue of int | RequestValue of unit | ChangeAlgorithm of advisorAlgo | ExecuteAlgorithm of unit

type advisorFullReturn = operation list * advisorStorage