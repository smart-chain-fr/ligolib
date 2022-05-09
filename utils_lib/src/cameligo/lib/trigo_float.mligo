#import "../lib/float.mligo" "Float"

type chebychev_intervals = Float.t * Float.t
type chebychev_coef = Float.t list 
type chebychev = (chebychev_intervals, chebychev_coef) map 

let zero : Float.t = {val=0 ; pow=0}
let pi : Float.t = {val=31415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679 ; pow=-100}
let two_pi : Float.t = Float.mul pi (Float.new 2 0)
let pi_half : Float.t = Float.div pi (Float.new 2 0)
let pi_quarter : Float.t = Float.div pi (Float.new 4 0)
let three_pi_half : Float.t = Float.mul pi_half (Float.new 3 0)
let three_pi_quarter : Float.t = Float.mul pi_quarter (Float.new 3 0)
let five_pi_quarter : Float.t = Float.mul pi_quarter (Float.new 5 0)
let seven_pi_quarter : Float.t = Float.mul pi_quarter (Float.new 7 0)
let pi_third : Float.t = Float.div pi (Float.new 3 0)
let pi_sixth : Float.t = Float.div pi (Float.new 6 0)

//1.414213562373095048801688724209698078569671875376948073176679737990732478462107038850387534327641572735013846230912297024924836055850737212644121497099935831413222665927505592755799950501152782060571
//1.7320508075688772935

let sqrt_2 : Float.t = {val=1414213562373095048801688724209; pow=-30}
let sqrt_3 : Float.t = {val=17320508075688772935; pow=-19}

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
            {val=6021947012555463;pow=-16};
            {val=513625166679107;pow=-15};
            {val=-10354634426296383;pow=-17};
            {val=-13732034234358675;pow=-18};
            {val=13586698380902013;pow=-19};
            {val=10726309440570181;pow=-20};
            {val=-7046296793891682;pow=-21};
            {val=-3963902510811801;pow=-22};
            {val=194995972671759;pow=-22};
            {val=8522923894416223;pow=-25};
            {val=-3351717514643582;pow=-26};
            {val=-11987008607938776;pow=-28};
            {val=3835820550079916;pow=-29};
        ]
    )
]

let find_chebychev_interval(p: Float.t) : chebychev_intervals option =
    let rec find (x, lst : Float.t * chebychev_intervals list) : chebychev_intervals option =
        match lst with
        | [] -> (None: chebychev_intervals option)
        | hd::tl -> if (Float.lte x hd.1) then (Some (hd)) else find(x, tl)
    in
    find(p, chebychev_lookup_intervals)

let sin(a, n : Float.t * nat) : Float.t = 
    let interval_opt : chebychev_intervals option = find_chebychev_interval(a) in
    let interval_cheby = match interval_opt with
    | None -> failwith("given angle is out of bound")
    | Some interval -> interval
    in
    let two = Float.new 2 0 in
    //let u = (x - (a+b)/2.0 )/ (b-a)/2.0
    let u = (Float.div
        (Float.sub a (Float.div (Float.add interval_cheby.0 interval_cheby.1) (two)))
        (Float.div (Float.sub interval_cheby.1 interval_cheby.0) (two))
    ) in
    let coef : chebychev_coef = match Map.find_opt interval_cheby chebychev_lookup_table with
    | None -> failwith("chebychev_lookup_intervals does not match chebychev_lookup_table")
    | Some coef -> coef
    in

    let coef_0 = Option.unopt (List.head_opt coef) in
    let coef_1 = Option.unopt (List.head_opt (Option.unopt (List.tail_opt coef))) in
    let y0 = Float.add coef_0 (Float.mul coef_1 u) in
    let one = Float.new 1 0 in
    let two = Float.new 2 0 in
    let t0 : Float.t = one in
    let t1 : Float.t = u in
    let coef_from_2 = Option.unopt (List.tail_opt (Option.unopt (List.tail_opt coef))) in
    let rec compute (i, acc, t_prev, t_prev_prev, n, coef : nat * Float.t * Float.t * Float.t * nat * chebychev_coef) : Float.t =
        if (i <= n) then
            let t_next_u = Float.sub (Float.mul (Float.mul two u) t_prev) t_prev_prev in
            let current_coef = Option.unopt (List.head_opt coef) in
            let rest_coef = Option.unopt (List.tail_opt coef) in
            let new_acc = Float.add acc (Float.mul t_next_u current_coef) in
            compute(i + 1n, new_acc, t_next_u, t_prev, n, rest_coef)
        else
            acc
    in
    compute(2n, y0, t1, t0, n, coef_from_2)

let rec sinus_symetry(sign, a, n : Float.t * Float.t * nat) : Float.t =
    // sin(-a) = - sin(a)
    if (Float.lt a zero) then
        sinus_symetry(Float.mul sign (Float.new (-1) 0), Float.mul a (Float.new (-1) 0), n)
    else
        let a_mod_two_pi = Float.modulo a two_pi in 
        //[0, pi_half]
        if (Float.lte a_mod_two_pi pi_half) then
            Float.mul sign (sin(a_mod_two_pi, n))
        //[pi_half, pi] -> sin(Pi/2 + a) = sin(Pi/2 - a)
        else if (Float.lte a_mod_two_pi pi) then
            let theta = Float.sub a_mod_two_pi pi_half in
            let half_pi_minus_a = Float.sub pi_half theta in
            Float.mul sign (sin(half_pi_minus_a, n))
        //[pi, two_pi] -> sin(Pi + a) = - sin(a)
        else if (Float.lt pi a_mod_two_pi) then
            let minus_pi = Float.sub a_mod_two_pi pi in 
            sinus_symetry(Float.mul sign (Float.new (-1) 0), minus_pi, n)
        else
            (failwith("ERROR out of bound angle") : Float.t)

let sinus(a, n : Float.t * nat) : Float.t =
    sinus_symetry(Float.new (1) 0, a, n)

let cosinus(a, n : Float.t * nat) : Float.t = 
    let plus_half_PI = Float.add a pi_half in 
    sinus_symetry(Float.new (1) 0, plus_half_PI, n)
