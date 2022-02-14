type t = 
[@layout:comb]
{
    approved_signers: address set;
    executed: bool;
    number_of_signer: nat;
    target_fa12: address;
    target_to: address;
    timestamp: timestamp;
    token_amount: nat;
}

let create (target_fa12: address) (target_to: address) (token_amount: nat) : t =
    { 
        target_fa12      = target_fa12;
        target_to        = target_to;
        token_amount     = token_amount;
        timestamp        = Tezos.now;
        approved_signers = Set.literal [Tezos.sender];
        number_of_signer = 1n;
        executed         = false;
    } 

let add_signer (proposal: t) (signer: address) (threshold: nat) : t = 
    let approved_signers : address set = Set.add signer proposal.approved_signers in
    let executed = Set.size approved_signers >= threshold || proposal.executed in
    { 
        proposal with 
        approved_signers = approved_signers;
        number_of_signer = proposal.number_of_signer + 1n ;
        executed         = executed 
    }
