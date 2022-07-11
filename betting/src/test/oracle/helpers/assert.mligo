(* Assert contract result is successful *)
let tx_success (res: test_exec_result) : unit =
    match res with
        | Fail (Rejected (error,_)) -> let () = Test.log(error) in failwith "Transaction should not fail"
        | Fail _ -> failwith "Transaction should not fail"
        | Success(_) -> Test.log("OK", res)

(* Assert contract call results in failwith with given string *)
let string_failure (res : test_exec_result) (expected : string) : unit =
    let _expected = Test.eval expected in
    let () = match res with
        | Fail (Rejected (actual,_)) -> assert (actual = _expected)
        | Fail (Balance_too_low err) -> failwith "Contract failed: Balance too low"
        | Fail (Other s) -> failwith s
        | Success _ -> failwith "Transaction should fail"
    in
    Test.log("OK", expected)

// (* Assert parameter with expected result *)
// let assert_parameter (ctr : contract) (parameter : string) (expected : string) : unit =
//     let _expected = Test.eval expected in
//     let () = match res with
//         | Fail (Rejected (actual,_)) -> assert (actual = _expected)
//         | Fail (Balance_too_low err) -> failwith "Contract failed: Balance too low"
//         | Fail (Other s) -> failwith s
//         | Success _ -> failwith "Transaction should fail"
//     in
//     Test.log("OK", expected)
