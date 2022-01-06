type advisorAlgo is int -> bool

type advisorStorage is record [
    indiceAddress : address;
    algorithm : advisorAlgo;
    result : bool;
]

type advisorEntrypoints is ReceiveValue of int | RequestValue of unit | ChangeAlgorithm of advisorAlgo

type advisorFullReturn is list(operation) * advisorStorage