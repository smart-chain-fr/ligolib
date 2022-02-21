#import "storage.mligo" "Storage"
#import "parameter.mligo" "Parameter"

type storage = Storage.Types.t
type parameter = Parameter.Types.t
type return = operation list * storage

let main(ep, store : parameter * storage) : return =
    match ep with 
    | Commit(p) -> Storage.Utils.commit(p, store)
    | Reveal(p) -> Storage.Utils.reveal(p, store)
