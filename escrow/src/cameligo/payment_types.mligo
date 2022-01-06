type fa12_transfer = address * (address * nat)

type currency = string

type escrowId = string

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
    escrows : (escrowId, escrow) big_map; 
    judges : (nat, address) map;
    votingContract : address
}

type returnPayment = operation list * paymentStorage

type payParameter = { 
    currency : currency;
    amount: nat;
    escrowId: escrowId
}

type createPayParameter = { 
    currency : currency;
    amount: nat;
    buyer : address;
    seller : address;
    escrowId: escrowId
}

type paymentEntrypoints = 
    | AddCurrency of (currency * address)
    | DeleteCurrency of currency
    | Pay of payParameter 
    | CancelPayment of escrowId
    | ReleasePayment of escrowId
    | SetEscrowcontract of (escrowId * address)
    | SetAdmin of address
