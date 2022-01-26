#import "../../src/cameligo/proxy.mligo" "Proxy"
#import "./proxy.test.mligo" "Test_Proxy"

let originate_and_test_e2e (main : Test_Proxy.main_fn) =
    let () = Test_Proxy._test_not_owner main in
    let () = Test_Proxy._test_not_zero_amount main in
    let () = Test_Proxy._test_transfer_ownership_success main in
    let () = Test_Proxy._test_add_version_success main in
    let () = Test_Proxy._test_set_version_success main in
    let () = Test_Proxy._test_add_version_then_set_version_success main in
    let () = Test_Proxy._test_increment_success_featurev1 main in
    let () = Test_Proxy._test_decrement_success_featurev1 main in
    let () = Test_Proxy._test_reset_success_featurev1 main in
    ()

let test_mutation =
    match Test.mutation_test_all Proxy.main originate_and_test_e2e with
        [] -> ()
        | ms ->
          let () = List.iter 
            (fun ((_, mutation) : unit * mutation) -> let () = Test.log mutation in ())
            ms 
          in
          failwith "Some mutation also passes the tests! ^^"
