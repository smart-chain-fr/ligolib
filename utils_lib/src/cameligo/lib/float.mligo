#import "../lib/math.mligo" "Math"

// n = a * 10^b
type t = { val : int; pow: int }

[@inline]
let new (val : int) (pow: int) : t = 
    { val=val; pow=pow }

[@inline]
let inverse (a : t) : t = 
    { val= 1n * Math.power(10n, 18n) / a.val; pow=(a.pow * -1) - 18n }


[@inline]
let add (a : t) (b : t) : t = 
    if (a.pow < b.pow) then
        { val= b.val * Math.power(10n, abs(b.pow - a.pow)) + a.val; pow=a.pow }
    else
        { val= a.val * Math.power(10n, abs(a.pow - b.pow)) + b.val; pow=b.pow }

[@inline]
let sub (a : t) (b : t) : t =
    if (a.pow < b.pow) then
        { val= a.val - b.val * Math.power(10n, abs(b.pow - a.pow)); pow=a.pow }
    else
        { val= a.val * Math.power(10n, abs(a.pow - b.pow)) - b.val; pow=b.pow }

[@inline]
let lt (a : t) (b : t) : bool = 
    if (a.val < 0) && (b.val > 0) then
        true
    else if (a.val > 0) && (b.val < 0) then
        false
    else 
        let diff = sub a b in
        diff.val < 0  

[@inline]
let lte (a : t) (b : t) : bool = 
        if (a.val < 0) && (b.val > 0) then
        true
    else if (a.val > 0) && (b.val < 0) then
        false
    else 
        let diff = sub a b in
        diff.val <= 0  

[@inline]
let gte (a : t) (b : t) : bool = 
    if (a.val >= 0) && (b.val < 0) then
        true
    else if (a.val <= 0) && (b.val > 0) then
        false
    else 
        let diff = sub a b in
        diff.val >= 0  

[@inline]
let gt (a : t) (b : t) : bool = 
    if (a.val > 0) && (b.val < 0) then
        true
    else if (a.val < 0) && (b.val > 0) then
        false
    else 
        let diff = sub a b in
        diff.val > 0  

[@inline]
let mul (a : t) (b : t) : t =
    { val= a.val * b.val ; pow=a.pow + b.pow }

[@inline]
let div (a : t) (b : t) : t =
    { val= a.val * Math.power(10n, 18n) / b.val ; pow=a.pow - b.pow - 18n }

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
    let resolve_positif (a: t) (prec: nat) : int =
        if (a.pow > 0) then
            a.val * Math.power(10n, abs(a.pow)) * Math.power(10n, prec) 
        else
            a.val * Math.power(10n, prec) / Math.power(10n, abs(-a.pow)) 
    in
    if (a.val < 0) then
        -1 * (resolve_positif (new (int(abs(a.val))) a.pow) prec)
    else
        resolve_positif a prec