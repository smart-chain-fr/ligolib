#import "../contracts/base58_convertor.mligo" "Convert"


let test =

    let _test_is_implicit = 
        //0x050a00000016 0000430d6ec166d9c623104776aaad3bb50615c6791f

        // IS_IMPLICIT
        // let is_implicit(elt: address) : bool = 
        //     let pack_elt : bytes = Bytes.pack elt in
        //     let () = Test.log((elt, pack_elt)) in
        //     let two_first : bytes = Bytes.sub 6n 2n pack_elt in 
        //     (two_first = 0x0000)
        // in

        let is_implicit(elt: address) : bool = 
            let pack_elt : bytes = Bytes.pack elt in
            let () = Test.log((elt, pack_elt)) in
            let size : nat = Bytes.length pack_elt in
            let is_imp : bytes = Bytes.sub 6n 1n pack_elt in
            let addr_bin : bytes = Bytes.sub 7n (abs(size - 7n)) pack_elt in
            let value : nat = Convert.Utils.bytes_to_nat(addr_bin) in
            let () = Test.log(value) in
            ( is_imp = 0x00 )
        in

        // helpers
        let concate ((acc, elt): bytes * bytes) : bytes = Bytes.concat acc elt in
        let rec split_bytes_rec(acc, payload : bytes list * bytes) : bytes list =
            let size : nat = (Bytes.length payload) in
            if size = 1n then
                payload :: acc
            else
                let one_last_bytes = Bytes.sub (abs(size - 1n)) 1n payload in
                let left_bytes = Bytes.sub 0n (abs(size - 1n)) payload in 
                split_bytes_rec(one_last_bytes :: acc, left_bytes)
        in
        let bytes_to_list (ch: bytes) : bytes list = split_bytes_rec(([]: bytes list), ch) in
        let bytes_from_list (lst: bytes list) : bytes = List.fold concate lst 0x in

        let read_nb_bytes (nb : nat) (payload_param: bytes) : bytes * bytes =
            let size : nat = (Bytes.length payload_param) in 
            let left_bytes : bytes = Bytes.sub 0n nb payload_param in
            let right_bytes = Bytes.sub nb (abs(size - nb)) payload_param in 
            (left_bytes, right_bytes)
        in
        //let (b1, to_read) = read_nb_bytes 1n pack_ref in
        //let (b2, to_read) = read_nb_bytes 1n to_read in
        //let (b3_b6, to_read) = read_nb_bytes 4n to_read in
        //let trspil_test : bytes = bytes_from_list(bytes_to_list(b3_b6)) in

        // TEST
        let test_addr_implicit : address list = [
            ("tz1hxxVY5jc6bsfCTzv27FLhVBZfKFaB164R" : address);
            ("tz1RyejUffjfnHzWoRp1vYyZwGnfPuHsD5F5" : address);
            ("tz1hHfjC5wX3gdQBZ6LyBWTrBczWQjktEu5E" : address);
            ("tz1fujCnFL1wQa7rtWKcvBvRk1uWoiDTQ5CX" : address);
            ("tz1Ytm4W7j6W4jj4EhnB854JfwEkTMUpRQQ2" : address);
            ("tz1MtU1ZH9cLSRjyrZXstEGxJcbRfvX4E9Ga" : address);
            ("tz1UbRzhYjQKTtWYvGUWcRtVT4fN3NESDVYT" : address);
            ("tz1Rka4HepbaCwH8K1fCn2Hq2GCjVLuRv4AL" : address);
        ] in
        let test_addr_non_implicit : address list = [
            ("KT1Cp18EbxDk2WcbC1YVUyGuwuvtzyujwu4U" : address);
            ("KT1Qg4FmXDmViQgyYLT5QkgZQSmPKvKjZbzn" : address);
            ("KT1CW6CgagaNoP95aDcp1B7PcwaAess66SYS" : address);
            ("KT1TwzD6zV3WeJ39ukuqxcfK2fJCnhvrdN1X" : address);
            ("KT1MsktCnwfS1nGZmf8QbaTpZ8euVijWdmkC" : address);
            ("KT1Xobej4mc6XgEjDoJoHtTKgbD1ELMvcQuL" : address);
            ("KT1LTmkz5J7vESxZjHqazzdhGohS5uTXEa2G" : address);
            ("KT1F7zytGMtjWvrZubpFTq7Px4ubaQybZMoH" : address);
            ("KT19T6ZqpUWvMYX9LH9FmCkahyEyGY27PEPT" : address);
            ("KT1RMfFJphfVwdbaJx7DhFrZ9du5pREVSEyN" : address);
            ("KT1P6fPe5KDGaHJwCRB5o5XzH8iSbRVsXReg" : address);
            ("KT1XkmNDDEcsjxgJJ3LVBme9bx86tNagYuKi" : address);
            ("KT1Uo3LThxuwmBjQBTJV486JAUMKrZ45TBkc" : address);
            ("KT1N2kdJLjyamWxjibFcyQKe7dNoaxf263tz" : address);
            ("KT1MWSBaGkVMEx4wHfxqPym427rLvTVM1siB" : address);
            ("KT1JZHtsz7r9uYLLRKGgLvP8HR5eM75MfrHU" : address);
            ("KT1GtoXddGuPfBSwdT1GCG9HQE7AMMKzWf3H" : address);
            ("KT1W6FrLW9d8Y6NVQzx487KCXrTGK1RWtJNh" : address);
            ("KT1WqRhUKCqnq7nwwtySk3SPP3ebyrKtfbx9" : address);
            ("KT1MCJsFdhpgKJaJ8t8o99tDuyB2DdjdpRUe" : address);
        ] in
        let all_tests : (address * bool) list = ([] : (address * bool) list) in
        let fill_expectation_true ((acc, elt) : (address * bool) list * address) : (address * bool) list = (elt, true) :: acc in
        let fill_expectation_false ((acc, elt) : (address * bool) list * address) : (address * bool) list = (elt, false) :: acc in
        let run_tests (all_tests : (address * bool) list) (f: (address) -> bool) : unit =
            let run_test (elt : (address * bool)) : unit = 
                let calculated : bool = f(elt.0) in
                let expected : bool = elt.1 in
                assert (calculated = expected)
            in 
            List.iter run_test all_tests
        in
        // for KT1... is_implicit() should answer false
        let all_tests = List.fold fill_expectation_false test_addr_non_implicit all_tests in
        // for tz1... is_implicit() should answer false
        let all_tests = List.fold fill_expectation_true test_addr_implicit all_tests in
        // Run test
        let () = run_tests all_tests is_implicit in

        Test.log("Test finished")
    in


    let _test_convert_bytes_to_nat = (* chest key/payload and time matches -> OK *)
    
        let payload : bytes = 0x00 in
        let value : nat = Convert.Utils.bytes_to_nat(payload) in
        let () = assert(value = 0n) in

        let payload : bytes = 0x0a in
        let value : nat = Convert.Utils.bytes_to_nat(payload) in
        let () = assert(value = 10n) in

        let payload : bytes = 0x0A in
        let value : nat = Convert.Utils.bytes_to_nat(payload) in
        let () = assert(value = 10n) in

        let payload : bytes = 0x2c in
        let value : nat = Convert.Utils.bytes_to_nat(payload) in
        let () = assert(value = 44n) in

        let payload : bytes = 0x2C in
        let value : nat = Convert.Utils.bytes_to_nat(payload) in
        let () = assert(value = 44n) in

        let payload : bytes = 0xFF in
        let value : nat = Convert.Utils.bytes_to_nat(payload) in
        let () = assert(value = 255n) in

        let payload : bytes = 0x1234 in
        let value : nat = Convert.Utils.bytes_to_nat(payload) in
        let () = assert(value = 4660n) in

        let payload : bytes = 0x001234 in
        let value : nat = Convert.Utils.bytes_to_nat(payload) in
        let () = assert(value = 4660n) in

        let payload : bytes = 0x123400 in
        let value : nat = Convert.Utils.bytes_to_nat(payload) in
        let () = assert(value = 4660n * 256n) in


        Test.log("Test finished")
    in
    ()

