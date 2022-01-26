(**
  Increment/Decrement contract  
*)

module Storage = struct 
  type t = int

  let add (s:t) (delta:int) = s + delta
  let sub (s:t) (delta:int) = s - delta
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
 | Reset         -> 0)
