#import "../contracts/bytes_utils.mligo" "Convert"


let test =

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
