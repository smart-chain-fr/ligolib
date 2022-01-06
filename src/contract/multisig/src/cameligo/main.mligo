#import "partials/methods.mligo" "MULTISIG"

let main (action, storage : MULTISIG.entrypoint * MULTISIG.storage_multisig) : MULTISIG.return =
    match action with
    | Create_operation()    -> MULTISIG.create_operation    storage operation_params
    | Sign(value)           -> MULTISIG.sign                storage operation_counter
