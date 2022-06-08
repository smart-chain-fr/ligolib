type collectionContract = address
type collectionOwner = address

type sell_proposal = {
    owner : address;
    token_id : nat;
    collectionContract : collectionContract;
    active : bool;
    price : tez;
    hasard_level : nat;
} 

type t = {
    next_sell_id : nat;
    active_proposals : nat set;
    sell_proposals : (nat, sell_proposal) big_map
}

