(** 
   This file implement the TZIP-12 protocol (a.k.a FA2) for NFT on Tezos
   copyright Wulfman Corporation 2021
*)

#import "errors.mligo" "Errors"
#import "address.mligo" "Address"
#import "operators.mligo" "Operators"
#import "tokenMetadata.mligo" "TokenMetadata"
#import "ledger.mligo" "Ledger"
#import "storage.mligo" "Storage"

type storage = Storage.t

(** Transfer entrypoint *)
type atomic_trans = [@layout:comb] {
   to_      : Address.t;
   token_id : nat;
}

type transfer_from = {
   from_ : Address.t;
   tx    : atomic_trans list
}
type transfer = transfer_from list

let transfer (type a) (t:transfer) (s:a storage) : operation list * a storage = 
   (* This function process the "tx" list. Since all transfer share the same "from_" address, we use a se *)
   let process_atomic_transfer (from_:Address.t) (ledger, t:Ledger.t * atomic_trans) =
      let {to_;token_id} = t in
      let ()     = Storage.assert_token_exist s token_id in
      let ()     = Operators.assert_authorisation s.operators from_ token_id in
      let ledger = Ledger.transfer_token_from_user_to_user ledger token_id from_ to_ in
      ledger
   in
   let process_single_transfer (ledger, t:Ledger.t * transfer_from ) =
      let {from_;tx} = t in
      let ledger     = List.fold_left (process_atomic_transfer from_) ledger tx in
      ledger
   in
   let ledger = List.fold_left process_single_transfer s.ledger t in
   let s = Storage.set_ledger s ledger in
   ([] : operation list), s
   
type request = {
   owner    : Address.t;
   token_id : nat;
}

type callback = [@layout:comb] {
   request : request;
   balance : nat;
}

type balance_of = [@layout:comb] {
   requests : request list;
   callback : callback list contract;
}

(** Balance_of entrypoint *)
let balance_of (type a) (b: balance_of) (s: a storage) : operation list * a storage =
   let {requests;callback} = b in
   let get_balance_info (request : request) : callback =
      let {owner;token_id} = request in
      let balance_ = Storage.get_balance s owner token_id in
      {request=request;balance=balance_}
   in
   let callback_param = List.map get_balance_info requests in
   let operation = Tezos.transaction callback_param 0tez callback in
   ([operation]: operation list),s

(** Update_operators entrypoint *)
type operator = [@layout:comb] {
   owner    : Address.t;
   operator : Address.t;
   token_id : nat; 
}
type unit_update      = Add_operator of operator | Remove_operator of operator
type update_operators = unit_update list

let update_ops (type a) (updates: update_operators) (s: a storage) : operation list * a storage =
   let update_operator (operators,update : Operators.t * unit_update) = match update with 
      Add_operator    {owner=owner;operator=operator;token_id=token_id} -> Operators.add_operator    operators owner operator token_id
   |  Remove_operator {owner=owner;operator=operator;token_id=token_id} -> Operators.remove_operator operators owner operator token_id
   in
   let operators = Storage.get_operators s in
   let operators = List.fold_left update_operator operators updates in
   let s = Storage.set_operators s operators in
   ([]: operation list),s

[@view] let get_balance (type a) (p, s : (Address.t * nat) * a storage) : nat = 
      let (owner, token_id) = p in
      let balance_ = Storage.get_balance s owner token_id in
      balance_

[@view] let total_supply (type a) ((token_id, s) : (nat * a storage)):  nat =
      let () = Storage.assert_token_exist s token_id in
      1n

[@view] let all_tokens (type a) ((_, s) : (unit * a storage)): nat list =
   s.token_ids
   
[@view] let is_operator (type a) ((op, s) : (operator * a storage)): bool =
      Operators.is_operator (s.operators, op.owner, op.operator, op.token_id)

[@view] let token_metadata (type a) ((p, s) : (nat * a storage)): TokenMetadata.data = 
      TokenMetadata.get_token_metadata p s.token_metadata