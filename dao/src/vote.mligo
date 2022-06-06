type choice = bool
type t = (choice * nat)
type votes = (address, t) map

(**
    [count (votes)] is the count of [votes].
    The count is a triple of total votes (for + againt),
    sum of votes for,
    and sum of votes against.
*)
let count (votes : votes) : (nat * nat * nat) =
  let folded =
    fun ((for, against), (_, (choice, vote)) : (nat * nat) * (address * (t))) ->
      if choice
      then (for + vote, against)
      else (for, against + vote) in
  let (for, against) = Map.fold folded votes (0n, 0n) in
  (for + against, for, against)
