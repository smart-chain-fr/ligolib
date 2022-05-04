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
        let angle = Trigo.zero in
        let (t0, t1, t2, t3, t4, t5) = Trigo.eval_chebychev_polynoms(angle) in
        let () = Test.log(t0) in
        let () = Test.log(t1) in
        let () = Test.log(t2) in
        let () = Test.log(t3) in
        let () = Test.log(t4) in
        let () = Test.log(t5) in
        
        let manual = Rational.sub ({p=-10354634426296383;q=100000000000000000}) {p=6021947012555463;q=10000000000000000} in
        let manual_resolved = Rational.resolve manual 3n in
        let () = Test.log(manual) in
        let () = Test.log(manual_resolved) in
        

        let angle = Trigo.zero in
        let sin_angle = Trigo.sin(angle) in
        let sin_angle_resolved = Rational.resolve sin_angle 1n  in
        let () = Test.log("sin(0)") in
        let () = Test.log(sin_angle) in
        let () = Test.log(sin_angle_resolved) in

        let () = assert(Trigo.sin(angle) = {p=0; q=1}) in

        let angle = Trigo.pi_half in
        let () = assert(Trigo.sin(angle) = {p=1; q=1}) in
        
        let angle = Trigo.pi in
        let () = assert(Trigo.sin(angle) = {p=0; q=1}) in
        
        let angle = Trigo.three_pi_half in
        let () = assert(Trigo.sin(angle) = {p=-1; q=1}) in
        
        let angle = Trigo.two_pi in
        let () = assert(Trigo.sin(angle) = {p=0; q=1}) in
        
        Test.log("Test 'trigo' finished")
    in
    ()

