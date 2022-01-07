type indiceStorage = int

type indiceEntrypoints = Increment of int | Decrement of int | SendValue of unit

type indiceFullReturn = operation list * indiceStorage