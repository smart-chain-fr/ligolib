#import "../src/lambda.mligo" "Lambda"

(* 
    Sample lambda code for an empty list of operations
    Notice that a type from the Lambda module is used
    See Makefile compile-lambda target for usage with ligo CLI
*)

let lambda_ : Lambda.operation_list =
  fun () -> ([] : operation list)
