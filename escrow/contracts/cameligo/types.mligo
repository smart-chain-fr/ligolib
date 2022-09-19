type fa12_transfer = address * (address * nat)

type currency = string

type escrow_id = string

type escrow =  {
    currency : currency;
    amount : nat;
    buyer : address;
    seller : address;
    escrowContract : address option;
    canceled : bool;
    released : bool;
    paid : bool;
}

type paymentStorage = {
    admin : address;
    currencies : (currency, address) map;
    escrows : (escrow_id, escrow) map; 
    judges : (nat, address) map;
    votingContract : address
}

type returnPayment = operation list * paymentStorage

type payParameter = { 
    currency : currency;
    amount: nat;
    escrow_id: escrow_id
}

type create_pay_parameter = { 
    currency : currency;
    amount: nat;
    buyer : address;
    seller : address;
    escrow_id: escrow_id
}

type paymentEntrypoints = 
    | SetAdmin of address
    | AddCurrency of (currency * address)
    | DeleteCurrency of currency
    | Pay of payParameter 
    | CancelPayment of escrow_id
    | ReleasePayment of escrow_id
    | SetEscrowContract of (escrow_id * address)