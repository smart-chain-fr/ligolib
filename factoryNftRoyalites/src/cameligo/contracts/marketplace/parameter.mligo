
type sell_proposal_param = {
    token_id : nat;
    collectionContract : address;
    price : tez;
}

type buy_param = {
    proposal_id : nat
}

type t = Sell of sell_proposal_param | Buy of buy_param