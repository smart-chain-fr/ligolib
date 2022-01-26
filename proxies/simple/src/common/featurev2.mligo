(**
  Enhanced Increment/Decrement contract
  The contract signature is preserved for compatibility with the proxy
*)

module Storage = struct 
  type t = (address, int) big_map

  let get_addr_val (s:t) (addr:address) = 
    match (Big_map.find_opt addr s) with 
      Some(n) -> n 
      | None -> 0

  let add (s:t) (delta:int) =
    let n = get_addr_val s Tezos.source in
    Big_map.update Tezos.source (Some(n + delta)) s

  let sub (s:t) (delta:int) =
    let n = get_addr_val s Tezos.source in
    Big_map.update Tezos.source (Some(n - delta)) s

  let reset (s:t) = 
    Big_map.update Tezos.source (Some(0)) s
end

type storage = Storage.t

type parameter =
  Increment of int
| Decrement of int
| Reset

type return = operation list * storage
   
let main (action, store : parameter * storage) : return =
 ([] : operation list),
 (match action with
   Increment (n) -> Storage.add store n
 | Decrement (n) -> Storage.sub store n
 | Reset         -> Storage.reset store)
