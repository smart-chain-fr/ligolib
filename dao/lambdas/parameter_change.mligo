#import "../src/lambda.mligo" "Lambda"

(* 
    A parameter change lambda is just a new record of type Config.t, 
    the storage will be updated with the differences when the lambda is 
    executed
*)

let lambda_ : Lambda.parameter_change =
  fun () ->
    {deposit_amount = 400n;
     refund_threshold = 32n;
     quorum_threshold = 67n;
     super_majority = 80n;
     start_delay = 86400n;
     voting_period = 604800n;
     timelock_delay = 86400n;
     timelock_period = 259200n;
     burn_address =
       ("tz1burnburnburnburnburnburnburjAYjjX" : address)}
