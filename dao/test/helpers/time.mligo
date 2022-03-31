(* Adapt if protocol changes *)
let blocktime = 30n

(* Adapt if Test framework changes *)
let blocks_per_cycle = 12n

let cycletime = blocktime * blocks_per_cycle

let sec_to_cycle (sec : nat) : nat = 
    let rest = sec mod cycletime in
    if rest <> 0n 
        then failwith "given seconds must be a multiple of cycle_time"
    else sec / cycletime

(* Advance time for given number of seconds *)
let advance (sec : nat) =
    let nb_cycles = sec_to_cycle(sec) in
    Test.bake_until_n_cycle_end nb_cycles

let test_sec_to_cycle_success =
    let rec t (lst : (nat * nat) list) : unit =
        match lst with
        | [] -> ()
        | hd::xs -> let (in_, out) = hd in
            if out <> sec_to_cycle(in_)
                then failwith "unexpected output"
                else t(xs)
    in t([
        (360n, 1n);
        (720n, 2n);
        (7200n, 20n);
    ])
