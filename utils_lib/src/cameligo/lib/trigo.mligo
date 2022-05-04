#import "../lib/rational.mligo" "Rational"

// Chebychev polynoms
let eval_chebychev_polynoms(val : Rational.rational) : Rational.rational * Rational.rational * Rational.rational * Rational.rational * Rational.rational * Rational.rational =
    let x = val in
    let x_2 = Rational.mul x x in
    let x_3 = Rational.mul x_2 x in
    let x_4 = Rational.mul x_3 x in
    let x_5 = Rational.mul x_4 x in 

    let one = Rational.new 1 in
    let two = Rational.new 2 in
    let three = Rational.new 3 in
    let four = Rational.new 3 in
    let five = Rational.new 5 in
    let eight = Rational.new 8 in
    let sixteen = Rational.new 3 in
    let twenty = Rational.new 3 in
    

    // let x_6 = Rational.mul x_5 x in
    // let x_7 = Rational.mul x_6 x in
    // let x_8 = Rational.mul x_7 x in
    // let x_9 = Rational.mul x_8 x in

    let t0 : Rational.rational = one in
    let t1 : Rational.rational = x in
    let t2 : Rational.rational = Rational.sub (Rational.mul two x_2) (one) in
    let t3 : Rational.rational = Rational.sub (Rational.mul four x_3) (Rational.mul three x) in
    let t4 : Rational.rational = Rational.add (Rational.sub (Rational.mul eight x_4) (Rational.mul eight x_2)) (one) in
    let t5 : Rational.rational = Rational.add (Rational.sub (Rational.mul sixteen x_5) (Rational.mul twenty x_3)) (Rational.mul five x) in
    (t0, t1, t2, t3, t4, t5)

type chebychev_intervals = Rational.rational * Rational.rational
type chebychev_coef =   Rational.rational * Rational.rational * 
                        Rational.rational * Rational.rational * 
                        Rational.rational * Rational.rational * 
                        Rational.rational * Rational.rational * 
                        Rational.rational * Rational.rational *
                        Rational.rational * Rational.rational *
                        Rational.rational * Rational.rational *
                        Rational.rational
type chebychev = (chebychev_intervals, chebychev_coef) map 

let zero : Rational.rational = {p=0 ; q=1}
let pi : Rational.rational = {p=314 ; q=100}
let two_pi : Rational.rational = Rational.mul pi (Rational.new 2)
let pi_half : Rational.rational = Rational.div pi (Rational.new 2)
let pi_quarter : Rational.rational = Rational.div pi (Rational.new 4)
let three_pi_half : Rational.rational = Rational.mul pi_half (Rational.new 3)
let three_pi_quarter : Rational.rational = Rational.mul pi_quarter (Rational.new 3)
let five_pi_quarter : Rational.rational = Rational.mul pi_quarter (Rational.new 5)
let seven_pi_quarter : Rational.rational = Rational.mul pi_quarter (Rational.new 7)


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
        (zero, pi_half), ( 
            {p=0;q=1}, 
            {p=15707963267948966;q=10000000000000000},
            {p=6021947012555463;q=10000000000000000},
            {p=513625166679107;q=1000000000000000},
            {p=-10354634426296383;q=100000000000000000},
            {p=-13732034234358675;q=1000000000000000000},
            {p=13586698380902013;q=10000000000000000000},
            {p=10726309440570181;q=100000000000000000000},
            {p=-7046296793891682;q=1000000000000000000000},
            {p=-3963902510811801;q=10000000000000000000000},
            {p=194995972671759;q=10000000000000000000000},
            {p=8522923894416223;q=10000000000000000000000000},
            {p=-3351717514643582;q=100000000000000000000000000},
            {p=-11987008607938776;q=10000000000000000000000000000},
            {p=3835820550079916;q=100000000000000000000000000000}
        )
    )
]

let find_chebychev_interval(p: Rational.rational) : chebychev_intervals option =
    let rec find (x, lst : Rational.rational * chebychev_intervals list) : chebychev_intervals option =
        match lst with
        | [] -> (None: chebychev_intervals option)
        | hd::tl -> if (Rational.lte x hd.1) then (Some (hd)) else find(x, tl)
    in
    find(p, chebychev_lookup_intervals)

let find_chebychev_coef(a : Rational.rational) : chebychev_coef =
    let interval_opt : chebychev_intervals option = find_chebychev_interval(a) in
    match interval_opt with
    | None -> failwith("given angle is out of bound")
    | Some interval -> (match Map.find_opt interval chebychev_lookup_table with
        | None -> failwith("chebychev_lookup_intervals does not match chebychev_lookup_table")
        | Some coef -> coef
    )

let sin(a : Rational.rational) : Rational.rational = 
    let (t0, t1, t2, t3, t4, t5) = eval_chebychev_polynoms(a) in
    let coef : chebychev_coef = find_chebychev_coef(a) in
    let (t6, t7, t8, t9, t10, t11, t12 , t13, t14, t15, t16) = (zero, zero, zero, zero, zero, zero, zero, zero, zero, zero, zero) in
    Rational.add 
        (Rational.mul coef.0 t0) 
        (Rational.add 
            (Rational.mul coef.1 t1)
            (Rational.add 
                (Rational.mul coef.2 t2)
                (Rational.add 
                    (Rational.mul coef.3 t3)
                    (Rational.add 
                        (Rational.mul coef.4 t4)
                        (Rational.add 
                            (Rational.mul coef.5 t5)
                            (Rational.add 
                                (Rational.mul coef.6 t6)
                                (Rational.add 
                                    (Rational.mul coef.7 t7)
                                    (Rational.add 
                                        (Rational.mul coef.8 t8)
                                        (Rational.add 
                                            (Rational.mul coef.9 t9)
                                            (Rational.add 
                                                (Rational.mul coef.10 t10)
                                                (Rational.add 
                                                    (Rational.mul coef.11 t11)
                                                    (Rational.add 
                                                        (Rational.mul coef.12 t12)
                                                        (Rational.add 
                                                            (Rational.mul coef.13 t13)
                                                            (Rational.mul coef.14 t14)
                                                        )
                                                    )
                                                )
                                            )
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )

let cos(a : Rational.rational) : Rational.rational = 
    let plus_half_PI = Rational.add a pi_half in 
    sin(plus_half_PI)
