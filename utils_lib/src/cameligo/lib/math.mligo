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

(** It computes the factorial n! for a given nat. (i.e. n*(n-1)*(n-2)*...*1n ) *)
let factorial (n : nat) : nat = 
    let rec fact(acc, i : nat * nat) : nat = 
        if (i < 2n) then acc else fact(acc * i, abs(i - 1n)) in
    fact(1n, n)
