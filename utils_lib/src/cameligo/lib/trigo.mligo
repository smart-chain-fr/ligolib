#import "../lib/rational.mligo" "Rational"

type chebychev_intervals = Rational.rational * Rational.rational
type chebychev_coef = Rational.rational list 
type chebychev = (chebychev_intervals, chebychev_coef) map 

let zero : Rational.rational = {p=0 ; q=1}
let pi : Rational.rational = {p=31415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679 ; q=10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000}
let two_pi : Rational.rational = Rational.mul pi (Rational.new 2)
let pi_half : Rational.rational = Rational.div pi (Rational.new 2)
let pi_quarter : Rational.rational = Rational.div pi (Rational.new 4)
let three_pi_half : Rational.rational = Rational.mul pi_half (Rational.new 3)
let three_pi_quarter : Rational.rational = Rational.mul pi_quarter (Rational.new 3)
let five_pi_quarter : Rational.rational = Rational.mul pi_quarter (Rational.new 5)
let seven_pi_quarter : Rational.rational = Rational.mul pi_quarter (Rational.new 7)

let pi_sixth : Rational.rational = Rational.div pi (Rational.new 6)

let sqrt_2 : Rational.rational = {p=141421356237; q=100000000000}
let sqrt_3 : Rational.rational = {p=173205080757; q=100000000000}

let chebychev_lookup_intervals : chebychev_intervals list = [
    // (zero,pi_quarter);
    // (pi_quarter,pi_half);
    // (pi_half,three_pi_quarter);
    // (three_pi_quarter,pi);
    // (pi,five_pi_quarter);
    // (five_pi_quarter,three_pi_half);
    // (three_pi_half,seven_pi_quarter);
    // (seven_pi_quarter,two_pi);
    (zero, pi_half)
]

//0.0, 1.5707963267948966, 0.6021947012555463, 0.513625166679107, -0.10354634426296383, -0.013732034234358675, 0.0013586698380902013, 0.00010726309440570181, -7.046296793891682e-06, -3.963902510811801e-07, 1.94995972671759e-08, 8.522923894416223e-10, -3.351717514643582e-11, -1.1987008607938776e-12, 3.835820550079916e-14, 4.163336342344337e-16, -6.591949208711867e-16, -1.9290125052862095e-15


let chebychev_lookup_table : chebychev = Map.literal [
    // ((zero,pi_quarter),({p=0;q=1}, {p=0;q=1}, {p=0;q=1}) );
    // ((pi_quarter,pi_half),({p=0;q=1}, {p=0;q=1}, {p=0;q=1}) );
    // ((pi_half,three_pi_quarter),({p=0;q=1}, {p=0;q=1}, {p=0;q=1}) );
    // ((three_pi_quarter,pi),({p=0;q=1}, {p=0;q=1}, {p=0;q=1}) );
    // ((pi,five_pi_quarter),({p=0;q=1}, {p=0;q=1}, {p=0;q=1}) );
    // ((five_pi_quarter,three_pi_half),({p=0;q=1}, {p=0;q=1}, {p=0;q=1}) );
    // ((three_pi_half,seven_pi_quarter),({p=0;q=1}, {p=0;q=1}, {p=0;q=1}) );
    // ((seven_pi_quarter,two_pi),({p=0;q=1}, {p=0;q=1}, {p=0;q=1}) );
    (
        (zero, pi_half), [ 
            {p=6021947012555463;q=10000000000000000};
            {p=513625166679107;q=1000000000000000};
            {p=-10354634426296383;q=100000000000000000};
            {p=-13732034234358675;q=1000000000000000000};
            {p=13586698380902013;q=10000000000000000000};
            {p=10726309440570181;q=100000000000000000000};
            {p=-7046296793891682;q=1000000000000000000000};
            {p=-3963902510811801;q=10000000000000000000000};
            {p=194995972671759;q=10000000000000000000000};
            {p=8522923894416223;q=10000000000000000000000000};
            {p=-3351717514643582;q=100000000000000000000000000};
            {p=-11987008607938776;q=10000000000000000000000000000};
            {p=3835820550079916;q=100000000000000000000000000000};
        ]
    )
]

let find_chebychev_interval(p: Rational.rational) : chebychev_intervals option =
    let rec find (x, lst : Rational.rational * chebychev_intervals list) : chebychev_intervals option =
        match lst with
        | [] -> (None: chebychev_intervals option)
        | hd::tl -> if (Rational.lte x hd.1) then (Some (hd)) else find(x, tl)
    in
    find(p, chebychev_lookup_intervals)

// let find_chebychev_coef(a : Rational.rational) : chebychev_coef =
//     let interval_opt : chebychev_intervals option = find_chebychev_interval(a) in
//     match interval_opt with
//     | None -> failwith("given angle is out of bound")
//     | Some interval -> (match Map.find_opt interval chebychev_lookup_table with
//         | None -> failwith("chebychev_lookup_intervals does not match chebychev_lookup_table")
//         | Some coef -> coef
//     )

let sin(a, n : Rational.rational * nat) : Rational.rational = 
    let interval_opt : chebychev_intervals option = find_chebychev_interval(a) in
    let interval_cheby = match interval_opt with
    | None -> failwith("given angle is out of bound")
    | Some interval -> interval
    in
    let two = Rational.new 2 in
    //let u = (x - (a+b)/2.0 )/ (b-a)/2.0
    let u = (Rational.div
        (Rational.sub a (Rational.div (Rational.add interval_cheby.0 interval_cheby.1) (two)))
        (Rational.div (Rational.sub interval_cheby.1 interval_cheby.0) (two))
    ) in
    let coef : chebychev_coef = match Map.find_opt interval_cheby chebychev_lookup_table with
    | None -> failwith("chebychev_lookup_intervals does not match chebychev_lookup_table")
    | Some coef -> coef
    in

    let coef_0 = Option.unopt (List.head_opt coef) in
    let coef_1 = Option.unopt (List.head_opt (Option.unopt (List.tail_opt coef))) in
    let y0 = Rational.add coef_0 (Rational.mul coef_1 u) in
    let one = Rational.new 1 in
    let two = Rational.new 2 in
    let t0 : Rational.rational = one in
    let t1 : Rational.rational = u in
    let coef_from_2 = Option.unopt (List.tail_opt (Option.unopt (List.tail_opt coef))) in
    let rec compute (i, acc, t_prev, t_prev_prev, n, coef : nat * Rational.rational * Rational.rational * Rational.rational * nat * chebychev_coef) : Rational.rational =
        if (i <= n) then
            let t_next_u = Rational.sub (Rational.mul (Rational.mul two u) t_prev) t_prev_prev in
            let current_coef = Option.unopt (List.head_opt coef) in
            let rest_coef = Option.unopt (List.tail_opt coef) in
            let new_acc = Rational.add acc (Rational.mul t_next_u current_coef) in
            compute(i + 1n, new_acc, t_next_u, t_prev, n, rest_coef)
        else
            acc
    in
    compute(2n, y0, t1, t0, n, coef_from_2)

let rec sinus_symetry(sign, a, n : Rational.rational * Rational.rational * nat) : Rational.rational =
    let a_mod_two_pi = Rational.modulo a two_pi in 
    //[0, pi_half]
    if (Rational.lte a_mod_two_pi pi_half) then
        Rational.mul sign (sin(a_mod_two_pi, n))
    //[pi_half, pi]
    else if (Rational.lte a_mod_two_pi pi) then
        let theta = Rational.sub a_mod_two_pi pi_half in
        let half_pi_minus_a = Rational.sub pi_half theta in
        Rational.mul sign (sin(half_pi_minus_a, n))
    //[pi, two_pi]
    else if (Rational.lt pi a_mod_two_pi) then
        let minus_pi = Rational.sub a_mod_two_pi pi in 
        sinus_symetry(Rational.new (-1), minus_pi, n)
    else
        (failwith("ERROR out of bound angle") : Rational.rational)

let sinus(a, n : Rational.rational * nat) : Rational.rational =
    sinus_symetry(Rational.new (1), a, n)

let cosinus(a, n : Rational.rational * nat) : Rational.rational = 
    let plus_half_PI = Rational.add a pi_half in 
    sin(plus_half_PI, n)
