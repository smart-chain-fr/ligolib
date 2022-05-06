#import "../lib/math.mligo" "Math"

type t = { p : int; q: int }

[@inline]
let new (init : int) : t = 
    { p= init; q=1 }

[@inline]
let inverse (a : t) : t = 
    { p= a.q; q=a.p }

[@inline]
let lt (a : t) (b : t) : bool = 
    (a.p * b.q < a.q * b.p)
[@inline]
let lte (a : t) (b : t) : bool = 
    (a.p * b.q <= a.q * b.p)

[@inline]
let add (a : t) (b : t) : t =
    { p= a.p * b.q + b.p * a.q ; q=a.q * b.q }

[@inline]
let sub (a : t) (b : t) : t =
    { p= a.p * b.q - b.p * a.q ; q=a.q * b.q }

[@inline]
let mul (a : t) (b : t) : t =
    { p= a.p * b.p ; q=a.q * b.q }

[@inline]
let div (a : t) (b : t) : t =
    { p= a.p * b.q ; q=a.q * b.p }

[@inline]
let modulo (a : t) (b : t) : t =
    let rec compute (a, b : t * t) : t =
        if (lt a b) then 
            a 
        else
            compute((sub a b), b)
    in
    compute(a, b)

[@inline]
let resolve (a: t) (prec: nat) : int =
    let input : t = if (a.p < 0) then
        { p= a.p * -1; q=a.q * -1 }
    else
        a
    in
    (input.p * Math.power(10n, prec)) / input.q

[@inline]
let reduce_power_10 (a: t): t =
    let (p,q) : int * int = (a.p, a.q) in
    let p_log_10 : nat = Math.log_10(abs(p)) in
    let max_power: nat = abs(p_log_10 - 1n) in
    let rec reduce_(a, indice_10_power : t * nat) : t = 
        if (indice_10_power <= 0n) then
            a
        else
            let divisor = Math.power(10n, indice_10_power) in
            if (p mod divisor = 0n) && (abs(q) >= 10n * divisor) then
                {p=p / divisor; q=q / divisor}
            else
                reduce_(a, abs(indice_10_power - 1n))
    in
    reduce_(a, max_power)

