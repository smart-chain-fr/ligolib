(**
 * Reversing
 *)
[@inline]
let reverse (type kind) (lst1 : kind list) : kind list =
  let rec reverse (type kind) ((lst1, res) : kind list * kind list) : kind list =
    match lst1 with
    | [] -> res
    | hd1 :: tl1 -> reverse (tl1, (hd1 :: res)) in
  reverse (lst1, ([] : kind list))

(**
 * Concatenation
 *)
[@inline]
let concat (type kind) (lst1 : kind list) (lst2 : kind list) : kind list =
  let rec concat (type kind) ((lst1, lst2, res) : kind list * kind list * kind list) : kind list =
    match lst1, lst2 with
    | []        , []         -> reverse res
    | []        , hd2 :: tl2 -> concat (([] : kind list) , tl2 , hd2 :: res)
    | hd1 :: tl1, lst2       -> concat (tl1, lst2, hd1 :: res) in
  concat (lst1, lst2, ([] : kind list))

(**
 * Insertion
 *)
[@inline]
let insert (type kind) (element : kind) (position : nat) (lst1 : kind list) : kind list =
  let rec insert (type kind) ((element, position, lst1, lst2) : kind * nat * kind list * kind list) : kind list =
    match lst1, position with 
    | []        , pos -> failwith "Position is highter than list length"
    | hd1 :: tl1, pos -> 
      if (pos = 0n) then
        let lst3 : kind list = element::lst2 in
        let lst4 : kind list = reverse lst3 in 
        concat lst4 lst1
      else
        insert (element, abs(pos - 1n), tl1, hd1 :: lst2) in
  insert (element, abs(position - 1n), lst1, ([] : kind list))



(**
 *  We need to create a generic entrypoint main for compilation that do nothing
 *)
let main (_action, store : bytes * bytes) : operation list * bytes = ([] : operation list), store
