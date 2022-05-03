#import "../lib/rational.mligo" "Rational"

type chebychev_intervals = Rational.rational * Rational.rational
type chebychev_polynoms = Rational.rational * Rational.rational * Rational.rational
type chebychev = (chebychev_intervals, chebychev_polynoms) map 

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
    (zero,pi_quarter);
    (pi_quarter,pi_half);
    (pi_half,three_pi_quarter);
    (three_pi_quarter,pi);

    (pi,five_pi_quarter);
    (five_pi_quarter,three_pi_half);
    (three_pi_half,seven_pi_quarter);
    (seven_pi_quarter,two_pi);
]

let chebychev_lookup_table : chebychev = Map.literal [
    ((zero,pi_quarter),({p=0;q=1}, {p=0;q=1}, {p=0;q=1}) );
    ((pi_quarter,pi_half),({p=0;q=1}, {p=0;q=1}, {p=0;q=1}) );
    ((pi_half,three_pi_quarter),({p=0;q=1}, {p=0;q=1}, {p=0;q=1}) );
    ((three_pi_quarter,pi),({p=0;q=1}, {p=0;q=1}, {p=0;q=1}) );

    ((pi,five_pi_quarter),({p=0;q=1}, {p=0;q=1}, {p=0;q=1}) );
    ((five_pi_quarter,three_pi_half),({p=0;q=1}, {p=0;q=1}, {p=0;q=1}) );
    ((three_pi_half,seven_pi_quarter),({p=0;q=1}, {p=0;q=1}, {p=0;q=1}) );
    ((seven_pi_quarter,two_pi),({p=0;q=1}, {p=0;q=1}, {p=0;q=1}) );
]

let find_chebychev_interval(p: Rational.rational) : chebychev_intervals option =
    let rec find (x, lst : Rational.rational * chebychev_intervals list) : chebychev_intervals option =
        match lst with
        | [] -> (None: chebychev_intervals option)
        | hd::tl -> if (Rational.lt x hd.1) then (Some (hd)) else find(x, tl)
    in
    find(p, chebychev_lookup_intervals)

let find_chebychev_polynoms(a : Rational.rational) : chebychev_polynoms =
    let interval_opt : chebychev_intervals option = find_chebychev_interval(a) in
    match interval_opt with
    | None -> failwith("given angle is out of bound")
    | Some interval -> (match Map.find_opt interval chebychev_lookup_table with
        | None -> failwith("chebychev_lookup_intervals does not match chebychev_lookup_table")
        | Some coef -> coef
    )

let sin(a : Rational.rational) : Rational.rational = 
    let coef : chebychev_polynoms = find_chebychev_polynoms(a) in
    Rational.add coef.0 (Rational.add (Rational.mul a coef.1) (Rational.mul a (Rational.mul a coef.2)))

let cos(a : Rational.rational) : Rational.rational = 
    let plus_half_PI = Rational.add a pi_half in 
    sin(plus_half_PI)
