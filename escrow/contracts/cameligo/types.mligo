// type fa12_transfer = address * (address * nat)

type whitelist = {
  address       : address;
  allowed       : bool;
}

type escrow_state =
    Initiated of unit       // initial status for the Escrow (originated)
    | Released of bool      // if the buyer agreed to the release of funds upon delivery
    | Cancelled of bool     // if the buyer cancelled the contract refunding their funds

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

type escrow =  {
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

type storage = {
    // admin           : address;
    // is_paused   : bool;
    // commission  : nat;
    // whitelist           : whitelist;
    // currencies  : (currency_type, address) map;,
    escrows_index   : nat;                  // index for Escrows map
    escrows         : (nat, address) map;   // list of originated escrows
}

type originate_escrow_parameter = { 
    valid_until		    : timestamp;
    buyer              	: user;
    seller	            : user;
    judge	            : judge;
    rules 		        : bytes;
}

type return = operation list * storage

type entrypoint = 
    | OriginateEscrow of originate_escrow_parameter

// type pay_parameter = { 
//     nat: nat;
//     currency : string;
//     amount: nat;
// }

// type create_pay_parameter = { 
//     nat: nat;
//     buyer : address;
//     seller : address;
//     currency : string;
//     amount: nat;
// }

// type entrypoint = 
//     | SetAdmin of address
//     | AddCurrency of (string * address)
//     | DeleteCurrency of string
//     | OriginateEscrow of originate_escrow_parameter
//     | SetEscrowContract of (nat * address)
//     | ReleasePayment of nat
//     | CancelPayment of nat
//     | Pay of pay_parameter 