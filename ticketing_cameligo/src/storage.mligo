type owner = address
type ticket_type = string
type ticket_value = timestamp * ticket_type ticket 

type 'a tickets_ = ((owner * ticket_type), 'a) big_map
type tickets = ticket_value tickets_

type ticket_prices = (ticket_type, tez) big_map

type data_storage = {
    prices : ticket_prices;
    ticket_duration : nat;
    metadata: (string, bytes) big_map;
}

type 'a t_ = [@layout:comb] {
    all_tickets : 'a tickets_;
    data : data_storage;
}

type t = ticket_value t_

