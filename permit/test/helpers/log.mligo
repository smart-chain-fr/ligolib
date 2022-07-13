(* Return str repeated n times *)
let repeat (str, n : string * nat) : string =
    let rec loop (n, acc: nat * string) : string = 
        if n = 0n then acc else loop (abs(n - 1n), acc ^ str)
    in loop(n, "")

(* 
    Log boxed lbl

    "+-----------+"
    "| My string |"
    "+-----------+"
*)
let describe (lbl : string) =
    let hr = "+" ^ repeat("-", String.length(lbl) + 2n) ^ "+" in 
    let () = Test.log hr in
    let () = Test.log ("| " ^ lbl ^ " |") in
    Test.log hr
