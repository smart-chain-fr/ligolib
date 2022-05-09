(** This function is the integer square root function. *)
let isqrt (y: nat) =
    if y > 3n then
        let z = y in
        let x = y / 2n + 1n in
        let rec iter (x, y, z: nat * nat * nat): nat =
            if x < z then
                iter ((y / x + x) / 2n, y, x)
            else
                z
        in
        iter (x, y, z)
    else if y <> 0n then
        1n
    else
        0n

(** return x ^ y *)
let power (x, y : nat * nat) : nat = 
    let rec multiply(acc, elt, last: nat * nat * nat ) : nat = if last = 0n then acc else multiply(acc * elt, elt, abs(last - 1n)) in
    multiply(1n, x, y)

(** It computes the factorial n! for a given nat n. (i.e. n*(n-1)*(n-2)*...*1n ) *)
let factorial (n : nat) : nat = 
    let rec fact(acc, i : nat * nat) : nat = 
        if (i < 2n) then acc else fact(acc * i, abs(i - 1n)) in
    fact(1n, n)

let min (a: nat) (b: nat) : nat =
    if (a < b) then a else b

let max (a: nat) (b: nat) : nat =
    if (a > b) then a else b

// let log_10 (x : nat) : nat =
//     //precalculated= [log(2), log(1.1), log(1.01), ... , log(1.000001)];
//     let precalculated : Rational.t list = [
//         {p=301029996; q=1000000000}; 
//         {p=41392685; q=1000000000}; 
//         {p=4321374; q=1000000000}; 
//         {p=434077; q=1000000000}; 
//         {p=43427; q=1000000000}; 
//         {p=4343; q=1000000000}; 
//         {p=434; q=1000000000}; 
//         {p=43; q=1000000000}] in
//     let k_init : nat  = 0n in
//     let y_init : nat = 0n in
//     let p_init : nat = 1n in
//     let func(acc, elt : (nat * Rational.t * Rational.t) * Rational.t) : (nat * Rational.t * Rational.t) =
//         let k : nat = acc.0 in
//         let l_k = elt in
//         let rec boucle(y, p) : t * t = 
//             let temp = p + p * Math.power(10n, - k) in
//             if (x >= temp) then
//                 boucle(y + l_k, temp)
//             else
//                 (y, p)
//         in
//         let (new_y, new_p) = boucle(acc.1, acc.2) in
//         (acc.0 + 1n, new_y, new_p)
//     in
//     let (k_final, y_final, p_final) = List.fold func precalculated (k_init, y_init, p_init) in
//     y_final

let log_10 (x : nat) : nat =
    let rec check_power(x, i : nat * nat) : nat =
        if (x mod power(10n, i) > 0n) then
            abs(i - 1n)
        else
            check_power(x, i + 1n)
    in 
    check_power(x, 1n)