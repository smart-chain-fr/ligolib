(** 
  This file implements a basic proxy example
*)

#import "constants.mligo" "Constants"
#import "errors.mligo" "Errors" 
#import "parameter.mligo" "Parameter"
#import "storage.mligo" "Storage"

type storage = Storage.Types.t
type parameter = Parameter.Types.t
type result = operation list * storage

(** Get contract address of current version *)
let get_current_addr (s:storage) = 
    match Map.find_opt s.version s.versions with 
          Some addr -> addr
        | None -> failwith Errors.undefined_version

(** 
  A proxy must specify all the callee's entry point it uses
  Generic calls delegation is not possible with michelson, as contract entry points
  must be specified with the CONTRACT instruction
  https://tezos.gitlab.io/michelson-reference/#instr-CONTRACT
*)
[@no_mutation]
let get_increment_entrypoint (addr:address) : int contract =
    match (Tezos.get_entrypoint_opt "%increment" addr : int contract option) with
          Some c -> c
        | None -> failwith Errors.undefined_receiver

[@no_mutation]
let get_decrement_entrypoint (addr:address) : int contract =
    match (Tezos.get_entrypoint_opt "%decrement" addr : int contract option) with
          Some c -> c
        | None -> failwith Errors.undefined_receiver

[@no_mutation]
let get_reset_entrypoint (addr:address) : unit contract =
    match (Tezos.get_entrypoint_opt "%reset" addr : unit contract option) with
          Some c -> c
        | None -> failwith Errors.undefined_receiver

(** Delegates/Routes to callee *)
let increment (s:storage) (n:int) : result =
    let addr = get_current_addr(s) in 
    let dest = get_increment_entrypoint(addr) in
    [@no_mutation] let op = Tezos.transaction n 0mutez dest in 
    ([op], s)

let decrement (s:storage) (n:int) : result =
    let addr = get_current_addr(s) in 
    let dest = get_decrement_entrypoint(addr) in
    [@no_mutation] let op = Tezos.transaction n 0mutez dest in 
    ([op], s)

let reset (s:storage) : result =
    let addr = get_current_addr(s) in 
    let dest = get_reset_entrypoint(addr) in
    [@no_mutation] let op = Tezos.transaction unit 0mutez dest in 
    ([op], s)

let main (action, store : parameter * storage) : result = 
    match action with 
        TransferOwnership addr -> 
          Constants.no_operation, 
          Storage.Utils.transfer_ownership store addr
        | AddVersion v -> 
          Constants.no_operation, 
          Storage.Utils.add_version store v 
        | SetVersion v -> 
          Constants.no_operation,
          Storage.Utils.set_version store v
        | Increment n -> increment store n
        | Decrement n -> decrement store n
        | Reset -> reset store
