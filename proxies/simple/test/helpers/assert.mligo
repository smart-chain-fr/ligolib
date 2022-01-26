let string_failure (res : test_exec_result) (expected : string) : unit =
    let expected = Test.eval expected in
    match res with
        | Fail (Rejected (actual,_)) -> assert (Test.michelson_equal actual expected)
        | Fail (Other) -> failwith "Transaction should fail with rejection"
        | Success _ -> failwith "Transaction should fail"
