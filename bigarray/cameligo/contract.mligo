(**
 * Last 
 *)
[@inline]
let last (type kind) (lst1 : kind list) : kind =
  let rec last (type kind) (lst1 : kind list) : kind =
    match lst1 with 
    | []         -> failwith "The list is empty"
    | hd1 :: tl1 -> (
      match tl1 with
      | []         -> hd1
      | hd2 :: tl2 -> last (tl1) ) 
  in
  last (lst1)

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
 * Get an element by his number position
 *)
[@inline]
let find (type kind) (position : nat) (lst1 : kind list) : kind =
  let rec get (type kind) ((position, lst1) : nat * kind list) : kind =
    match lst1 with
    | []         -> failwith "Position is highter than list length"
    | hd1 :: tl1 ->
      if (position = 0n) then hd1
      else get (abs(position - 1n), tl1) in
  get (position, lst1)

(**
 * Set an element by his number position
 *)
[@inline]
let set (type kind) (element : kind) (position : nat) (lst1 : kind list) : kind list =
  let rec set (type kind) ((element, position, lst1, res) : kind * nat * kind list * kind list) : kind list =
    match lst1 with
    | []         -> failwith "Position is highter than list length"
    | hd1 :: tl1 ->
      if (position = 0n) then 
        let lst2 : kind list = reverse (element :: res) in
        concat lst2 tl1
      else set (element, abs(position - 1n), tl1, hd1 :: res) in
  set (element, position, lst1, ([] : kind list))

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
  insert (element, position, lst1, ([] : kind list))

(**
 * Drop
 *)
[@inline]
let drop (type kind) (position : nat) (lst1 : kind list) : kind list =
  let rec drop (type kind) ((position, lst1, lst2) : nat * kind list * kind list) : kind list =
    match lst1 with 
    | []         -> failwith "Position is highter than list length"
    | hd1 :: tl1 -> 
      if (position = 0n) then
        let lst3 : kind list = reverse lst2 in 
        concat lst3 tl1
      else
        drop (abs(position - 1n), tl1, hd1 :: lst2) in
  drop (position, lst1, ([] : kind list))

(**
 * take
 *)
[@inline]
let take (type kind) (i : nat) (lst : kind list) : kind list =
  let rec take (type kind) ((i, lst, res) : nat * kind list * kind list) : kind list =
    if (i = 0n ) then reverse res
    else match lst with
      | []         -> reverse res
      | hd1 :: tl1 -> take (abs(i-1n), tl1, hd1 :: res) in
  take (i, lst, ([] : kind list))
  
(**
 * Slice
 *)
[@inline]
let slice (type kind) (i : nat) (k : nat) (lst : kind list) : kind list =
  let rec slice (type kind) ((i, k, lst) : nat * nat * kind list) : kind list =
    if (i = 0n ) then 
      let extract : nat = abs(k-i) in
      take extract lst
    else match lst with
      | []         -> []
      | hd1 :: tl1 -> slice (abs(i-1n), k, tl1) in
  slice (i, k, lst)
  
(**
 * Split
 *)
[@inline]
let split (type kind) (i : nat) (lst : kind list) : kind list * kind list =
  let rec split (type kind) ((i, lst1, lst2): nat * kind list * kind list) : kind list * kind list =
    if (i = 0n ) then let lstr = reverse lst2 in (lstr, lst1)
    else match lst1 with
      | []         -> let lstr = reverse lst2 in (lstr, lst1)
      | hd1 :: tl1 -> split (abs(i-1n), tl1, hd1 :: lst2) in
  split (i, lst, ([] : kind list))

(**
 * Rotate to the left
 *)
[@inline]
let rotate (type kind) (i : nat) (lst : kind list) : kind list =
  let rec rotate (type kind) ((i, lst, res) : nat * kind list * kind list) : kind list =
    if (i = 0n ) then 
      let lstr = reverse res in
      concat lst lstr
    else match lst with
      | []         -> reverse res
      | hd1 :: tl1 -> rotate (abs(i-1n), tl1, hd1 :: res) in
  rotate (i, lst, ([] : kind list))



// (**
//  * compare (not working )
//  *)
// [@inline]
// let compare (type kind) (element1 : kind) (element2 : kind) : bool =
//   if element1 = element2 then true
//   else false


// (**
//  * Remove (not working )
//  *)
// [@inline]
// let remove (type kind) (element : kind) (lst : kind list) : kind list =
//   let rec remove (type kind) ((element, lst, res) : kind * kind list * kind list) : kind list =
//     match lst with
//       | []         -> reverse res
//       | hd1 :: tl1 -> 
//         let a : kind = hd1 in
//         let b : kind = element in 
//         if a = b then remove (element, tl1, res)
//         else remove (element, tl1, hd1 :: res) 
//     in
//   remove (element, lst, ([] : kind list))




// example of type origination

//  type ('p,'s) originated = ('p,'s) typed_address * 'p contract

// let originate_from_file (type s p) (file_path: string) (mainName : string) (views: string list) (storage: s) : (p,s) originated =
//     let storage_value = Test.compile_value storage in
//     let (address_contract, code_contract, _) = Test.originate_from_file file_path mainName storage_value 0tez in
//     let taddress_contract = (Test.cast_address address_contract : (p, s) typed_address) in
//     taddress_contract, Test.to_contract taddress_contract
// and then you can call this function.
// let (typed_address_multi,_) : (Parameter.Types.t, Storage.Types.t) originated = originate_from_file "..." "n" ([]: string list) initial_storage_multisig in ...