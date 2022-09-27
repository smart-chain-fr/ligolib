type whitelist = {
  id       : address;
}

type escrow_state =
    Initiated of unit
    | Released of bool  // if the buyer agreed to the release of funds upon delivery
    | Cancelled of bool // if the buyer cancelled the contract refunding their funds

type currency_type =
    XTZ of unit
    | FA12 of address
    | FA2 of address

type user = {
  address           : address;          // user locking/receiving the funds
  currency_type     : currency_type;    // type of funds (XTZ/FA12/FA2) used on the contract
  currency_amount   : nat;              // amount of funds used on the contract
}

type judge = {
  address           : address;          // selling user receiving the funds
  judge_summon      : bool;             // if the litigation has been called (dispute on)
  judge_ruling      : (bool * nat);     // the judge's ruling if there is a litigation or not, and if TRUE : percentage sent to Seller
}

type storage =  {
    created_at		    : timestamp;	        // timestamp of escrow creation
    valid_until		    : timestamp;	        // timestamp of escrow expiry
    buyer		        : user;	                // buying user locking the funds
    buyer_approved	    : bool; 		        // if the buyer approved the Escrow rules
    // whitelist             : whitelist;            // whitelist of approved sellers
    seller	            : user;	                // selling user receiving the funds
    seller_approved 	: bool; 		        // if the seller approved the Escrow rules
    judge	            : judge;	            // judge user to be defined in case of dispute
    rules 		        : bytes;	            // text/IPFS link allowing both parties to agree on the task
    escrow_state	    : escrow_state;   
}

type entrypoint = 
    | SetSeller of user
    | Approve of user

type return = operation list * storage

let set_seller (param, store : user * storage) : return = 
    let _check_if_buyer : unit = assert_with_error (Tezos.get_sender () = store.buyer.address) "Buyer Exclusive" in
    ( ([] : operation list), { store with seller = param })

let approve (_param, store : user * storage) : return = 
    // let _check_if_buyer : unit = assert_with_error (Tezos.get_sender () = store.buyer.address) "Buyer Exclusive" in
    ( ([] : operation list), store )


let main (p, s : entrypoint * storage) : return = 
    match p with
    | SetSeller (x) -> set_seller (x, s)
    | Approve (x) -> approve (x, s)