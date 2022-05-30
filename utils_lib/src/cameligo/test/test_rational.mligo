#import "../lib/rational.mligo" "Rational"


let test =

    let _test_rational = 

        let a = Rational.new 6 in
        let a = Rational.inverse a in
        let value_resolved : int = Rational.resolve a 3n in
        let () = assert(value_resolved = 166) in

        let a : Rational.t = { p=1; q=6 } in
        let value_resolved : int = Rational.resolve a 3n in
        let () = assert(value_resolved = 166) in

        let a : Rational.t = { p=-1; q=6 } in
        let value_resolved : int = Rational.resolve a 3n in
        let () = assert(value_resolved = -166) in

        let a : Rational.t = { p=1; q=3 } in
        let b : Rational.t = { p=1; q=2 } in
        let value : Rational.t = Rational.add a b in
        let () = assert(value = { p=5; q=6 }) in
        let value_resolved : int = Rational.resolve value 3n in
        let () = assert(value_resolved = 833) in

        let a : Rational.t = { p=1; q=3 } in
        let b : Rational.t = { p=1; q=2 } in
        let value : Rational.t = Rational.sub a b in
        let () = assert(value = { p=-1; q=6 }) in
        let value_resolved : int = Rational.resolve value 3n in
        let () = assert(value_resolved = -166) in

        let a : Rational.t = { p=1; q=3 } in
        let b : Rational.t = { p=1; q=2 } in
        let value : Rational.t = Rational.mul a b in
        let () = assert(value = { p=1; q=6 }) in
        let value_resolved : int = Rational.resolve value 3n in
        let () = assert(value_resolved = 166) in

        let a : Rational.t = { p=1; q=3 } in
        let b : Rational.t = { p=1; q=2 } in
        let value : Rational.t = Rational.div a b in
        let () = assert(value = { p=2; q=3 }) in
        let value_resolved : int = Rational.resolve value 3n in
        let () = assert(value_resolved = 666) in

        Test.log("Test finished")
    in
    // let _test_rational_reduce = 
    //     let a : Rational.t = { p=123000; q=10000000 } in
    //     let a_log_10 : Rational.t = Rational.reduce_power_10 a in
    //     let () = Test.log(a_log_10) in

    //     let a : Rational.t = { p=12300000000; q=1000000000000 } in
    //     let a_log_10 : Rational.t = Rational.reduce_power_10 a in
    //     let () = Test.log(a_log_10) in

    //     let a : Rational.t = { p=123456789; q=100000000000000 } in
    //     let a_log_10 : Rational.t = Rational.reduce_power_10 a in
    //     let () = Test.log(a_log_10) in

    //     let a : Rational.t = { p=1234567891234567891234567891234567891234567891234567891234567891234567891234567891234567891234567890000000000; q=1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 } in
    //     let a_log_10 : Rational.t = Rational.reduce_power_10 a in
    //     let () = Test.log(a_log_10) in

    //     Test.log("Test finished")
    // in
    ()

