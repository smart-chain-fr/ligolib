#import "storage.mligo" "Storage"
#import "parameter.mligo" "Parameter"
#import "errors.mligo" "Errors"

type storage = Storage.t
type parameter = Parameter.t
type return = operation list * storage

let main(param, store : parameter * storage) : return =
    match param with
    | Entrypoint_1 _p -> (([] : operation list), store)
    | Entrypoint_2 _p -> (([] : operation list), store)
