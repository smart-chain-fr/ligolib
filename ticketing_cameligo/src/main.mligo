#import "storage.mligo" "Storage"
#import "parameter.mligo" "Parameter"
#import "errors.mligo" "Errors"
//#import "generic_fa2/core/instance/NFT.mligo" "NFT_FA2"
//#import "generic_fa2/core/common/ledger.mligo" "NFT_FA2_LEDGER"

type storage = Storage.t
type parameter = Parameter.t
type return = operation list * storage

//type store = NFT_FA2.Storage.t
//type ext = NFT_FA2.extension
//type ext_storage = ext store


let buyTicket(param, store : Parameter.buyTicketParam * (Storage.data_storage * Storage.tickets)) : return =
   let (data_storage, tickets_map) = store in
   let {
      ticket_type = ticket_type;
      ticket_amount = ticket_amount;
      ticket_owner = ticket_owner;
   } = param in

   // verify amount
   let _check_amount : unit = assert_with_error(ticket_amount >= 1n) "Invalid ticket amount" in
   let price_per_type : tez = match Big_map.find_opt ticket_type data_storage.prices with
   | None -> failwith("No price specified for this ticket_type")
   | Some price -> price
   in
   let _check_zero_amount = assert_with_error (Tezos.get_amount() > 0mutez) "Expects some tez !" in
   let _check_given_amount = assert_with_error (Tezos.get_amount() = ticket_amount * price_per_type) "Insuffisant amount" in

   // retrieve ticket from ticket_map
   let (ticket, ticket_map) = Big_map.get_and_update (ticket_owner, ticket_type) (None : Storage.ticket_value option) tickets_map in
   
   // create/join new ticket
   let new_ticket = match ticket with
   | None -> Tezos.create_ticket ticket_type ticket_amount
   | Some t -> 
      let nt = Tezos.create_ticket ticket_type ticket_amount in
      (
         match Tezos.join_tickets (t.1, nt) with
         | None -> failwith("could not join tickets")
         | Some t_j -> t_j
      )
   in
   // update ticket_map
   let (_, new_ticket_map) = Big_map.get_and_update (ticket_owner, ticket_type) ((Some(Tezos.get_now(), new_ticket)) : Storage.ticket_value option) ticket_map in
   (([] : operation list), { data = data_storage; all_tickets = new_ticket_map })


let redeemTicket(param, store : Parameter.redeemTicketParam * (Storage.data_storage * Storage.tickets)) : return =
   let (data_storage, tickets_map) = store in 
   let { ticket_type = ticket_type; ticket_amount = ticket_amount } = param in
   // retrieve ticket from ticket_map
   let (ticket_opt, ticket_map) = Big_map.get_and_update (Tezos.get_sender(), ticket_type) (None : Storage.ticket_value option) tickets_map in
   let modified_tickets_map : Storage.tickets = match ticket_opt with
   | None -> (failwith("No tickets") : Storage.tickets)
   | Some tkt -> 
      let (ticket_creation_timestamp, ticket) = tkt in
      let _check_ticket_validity : unit = assert_with_error 
         (ticket_creation_timestamp + int(data_storage.ticket_duration) > Tezos.get_now()) 
         "Ticket expired" 
      in
      let ((_ticketer, (_value, amt)), ticket) = Tezos.read_ticket ticket in
      let _check_zero_amount : unit = assert_with_error (amt > 0n) "Ticket amount is zero" in
      if (amt = ticket_amount) then
         ticket_map
      else
         (
            match Tezos.split_ticket ticket (abs(amt - ticket_amount),ticket_amount) with
            | None -> failwith("unsplittable ticket")
            | Some splitted_tickets ->
               let (resulting_ticket, _to_delete_ticket) = splitted_tickets in 
               let (_, new_ticket_map) = Big_map.get_and_update (Tezos.get_sender(), ticket_type) ((Some(ticket_creation_timestamp, resulting_ticket)) : Storage.ticket_value option) ticket_map in
               new_ticket_map
         )
   in
   (([] : operation list), { data = data_storage; all_tickets = modified_tickets_map })

let main(p, store : parameter * storage) : return =
   let { data = d; all_tickets = tickets_map} = store in
   match p with
   | BuyTicket param -> buyTicket(param, (d, tickets_map))
   | RedeemTicket param -> redeemTicket(param, (d, tickets_map))

