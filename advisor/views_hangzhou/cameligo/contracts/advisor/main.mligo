#import "errors.mligo" "Errors"
#import "parameter.mligo" "Parameter"
#import "storage.mligo" "Storage"

type storage = Storage.Types.t
type parameter = Parameter.Types.t
type return = operation list * storage

let advisorMain(ep, store : Parameter.Types.t * Storage.Types.t) : return = 
    ([] : operation list), (match ep with
    | ChangeAlgorithm(p) -> Storage.Utils.change(p, store)
    | ExecuteAlgorithm(_p) -> Storage.Utils.executeAlgorithm(store) 
    )