#import "./config.mligo" "Config"
#import "./errors.mligo" "Errors"

type kind = ParameterChange | OperationList
type t = bytes * kind
type parameter_change = (unit -> Config.t)
type operation_list = (unit -> operation list)

(**
    [validate(lambda_opt, packed)] validates that a [lambda_opt]
    lambda is compatible with [packed] bytes.
    Raises [Errors.lambda_not_found] if the lambda does not exists.
    Raises [Errors.lambda_wrong_packed_data] if the recorded hash is not matching
    a sha256 of given [packed] bytes.
*)
let validate (lambda_opt, packed : t option * bytes) : t =
    match lambda_opt with
        None -> failwith Errors.lambda_not_found
        | Some(lambda_) -> let _check_hash = assert_with_error
            (lambda_.0 = Crypto.sha256 packed)
            Errors.lambda_wrong_packed_data
            in lambda_
