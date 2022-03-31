type choice = bool
type t = (choice * nat)
type votes = (address, t) map

(**
    [count (votes)] is the count of [votes].
    The count is a triple of total votes, 
    sum of yes (true), 
    and sum of no (false).
*)
let count (votes : votes) : (nat * nat * nat) =
  let folded =
    fun (acc, v : (nat * nat) * (address * (t))) ->
      if v.1.0
      then (acc.0 + v.1.1, acc.1)
      else (acc.0, acc.1 + v.1.1) in
  let (x, y) = Map.fold folded votes (0n, 0n) in
  (x + y, x, y)
