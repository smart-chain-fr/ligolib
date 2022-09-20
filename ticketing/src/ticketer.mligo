module Constants =
  struct
    let no_operation : operation list = []
  end

module Errors =
  struct
    let cannot_join_tickets = "CANNOT_JOIN_TICKETS"
    let wrong_amount = "WRONG_AMOUNT"
  end

type tickets = (address, unit ticket) big_map
type storage_data = {
    price : tez;
}
type storage = {data : storage_data; tickets : tickets}
type result = operation list * storage

let buy_ticket ({data = data; tickets = tickets} : storage)
: result =
  let _check =
    assert_with_error
      (Tezos.get_amount () >= data.price && (Tezos.get_amount () mod data.price) = 0tez)
      Errors.wrong_amount in
  let nb_tickets = (Tezos.get_amount () / data.price) in
  let owner = (Tezos.get_sender ()) in
  let (owned_tickets_opt, tickets) =
    Big_map.get_and_update
      owner
      (None : unit ticket option)
      tickets in
  let new_ticket = Tezos.create_ticket unit nb_tickets in
  let join_tickets =
    match owned_tickets_opt with
      None -> new_ticket
    | Some owned_tickets ->
        (match Tezos.join_tickets
                 (owned_tickets, new_ticket)
         with
           None -> failwith Errors.cannot_join_tickets
         | Some joined_tickets -> joined_tickets) in
  let (_, tickets) =
    Big_map.get_and_update owner (Some join_tickets) tickets in
  Constants.no_operation, {data = data; tickets = tickets}

let main (_, store : unit * storage) : result =
  buy_ticket (store)
