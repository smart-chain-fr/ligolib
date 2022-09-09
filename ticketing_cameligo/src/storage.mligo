type owner = address
type ticket_type = string
type ticket_value = timestamp * ticket_type ticket 
type tickets = ((owner * ticket_type), ticket_value) big_map

type ticket_prices = (ticket_type, tez) big_map

type data_storage = {
    prices : ticket_prices;
    metadata: (string, bytes) big_map;
}

type t = [@layout:comb] {
    all_tickets : tickets;
    data : data_storage;
}

