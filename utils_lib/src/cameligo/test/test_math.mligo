#import "../lib/math.mligo" "Math"
#import "../lib/rational.mligo" "Rational"
#import "../lib/trigo.mligo" "Trigo"


let test =

    let _test_isqrt = 

        let () = assert(Math.isqrt(4n) = 2n) in
        let () = assert(Math.isqrt(8n) = 2n) in
        let () = assert(Math.isqrt(9n) = 3n) in
        let () = assert(Math.isqrt(15n) = 3n) in
        let () = assert(Math.isqrt(16n) = 4n) in
        let () = assert(Math.isqrt(17n) = 4n) in

        Test.log("Test 'isqrt' finished")
    in
    let _test_factorial = 

        let () = assert(Math.factorial(0n) = 1n) in
        let () = assert(Math.factorial(1n) = 1n) in
        let () = assert(Math.factorial(2n) = 2n) in
        let () = assert(Math.factorial(3n) = 6n) in
        let () = assert(Math.factorial(4n) = 24n) in
        let () = assert(Math.factorial(5n) = 120n) in
        let () = assert(Math.factorial(6n) = 720n) in
        
        Test.log("Test 'factorial' finished")
    in
    let _test_trigo = 
        let error_threshold = (Rational.inverse (Rational.new (int(Math.power(10n, 12n))))) in
        // sin(0)
        let angle = Trigo.zero in
        let expected = (Rational.new 0) in
        let diff = Rational.sub (Trigo.sinus(angle, 11n)) expected in
        let error = Rational.resolve diff 12n in
        let () = Test.log(error) in
        let () = assert(Rational.lt diff error_threshold ) in

        // sin(PI/2)
        let angle = Trigo.pi_half in
        let expected = (Rational.new 1) in
        let diff = Rational.sub (Trigo.sinus(angle, 11n)) expected in
        let error = Rational.resolve diff 12n in
        let () = Test.log(error) in
        let () = assert(Rational.lt diff error_threshold ) in

        // sin(PI)
        let angle = Trigo.pi in
        let expected = (Rational.new 0) in
        let diff = Rational.sub (Trigo.sinus(angle, 11n)) expected in
        let error = Rational.resolve diff 12n in
        let () = Test.log(error) in
        let () = assert(Rational.lt diff error_threshold ) in

        // sin(3*PI/2)
        let angle = Trigo.three_pi_half in
        let expected = (Rational.new (-1)) in
        let diff = Rational.sub (Trigo.sinus(angle, 11n)) expected in
        let error = Rational.resolve diff 12n in
        let () = Test.log(error) in
        let () = assert(Rational.lt diff error_threshold ) in
        
        // sin(2*PI)
        let angle = Trigo.two_pi in
        let expected = (Rational.new 0) in
        let diff = Rational.sub (Trigo.sinus(angle, 11n)) expected in
        let error = Rational.resolve diff 12n in
        let () = Test.log(error) in
        let () = assert(Rational.lt diff error_threshold ) in

        // sin(PI/4)
        let angle = Trigo.pi_quarter in
        let expected = (Rational.div Trigo.sqrt_2 (Rational.new 2)) in
        let diff = Rational.sub (Trigo.sinus(angle, 12n)) expected in
        let error = Rational.resolve diff 12n in
        let () = Test.log(error) in
        let () = assert(Rational.lt diff error_threshold ) in

        // sin(PI/6)
        let angle = Trigo.pi_sixth in
        let expected = (Rational.div Trigo.sqrt_3 (Rational.new 2)) in
        let diff = Rational.sub (Trigo.sinus(angle, 12n)) expected in
        let error = Rational.resolve diff 12n in
        let () = Test.log(error) in
        let () = assert(Rational.lt diff error_threshold ) in

        Test.log("Test 'trigo' finished")
    in
    ()

