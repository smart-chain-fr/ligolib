#import "../lib/math.mligo" "Math"

type rational = { p : int; q: int }

[@inline]
let new (init : int) : rational = 
    { p= init; q=1 }

[@inline]
let inverse (a : rational) : rational = 
    { p= a.q; q=a.p }

[@inline]
let lt (a : rational) (b : rational) : bool = 
    (a.p * b.q < a.q * b.p)
[@inline]
let lte (a : rational) (b : rational) : bool = 
    (a.p * b.q <= a.q * b.p)

[@inline]
let add (a : rational) (b : rational) : rational =
    { p= a.p * b.q + b.p * a.q ; q=a.q * b.q }

[@inline]
let sub (a : rational) (b : rational) : rational =
    { p= a.p * b.q - b.p * a.q ; q=a.q * b.q }

[@inline]
let mul (a : rational) (b : rational) : rational =
    { p= a.p * b.p ; q=a.q * b.q }

[@inline]
let div (a : rational) (b : rational) : rational =
    { p= a.p * b.q ; q=a.q * b.p }

[@inline]
let modulo (a : rational) (b : rational) : rational =
    let rec compute (a, b : rational * rational) : rational =
        if (lt a b) then 
            a 
        else
            compute((sub a b), b)
    in
    compute(a, b)

[@inline]
let resolve (a: rational) (prec: nat) : int =
    let input : rational = if (a.p < 0) then
        { p= a.p * -1; q=a.q * -1 }
    else
        a
    in
    (input.p * Math.power(10n, prec)) / input.q
