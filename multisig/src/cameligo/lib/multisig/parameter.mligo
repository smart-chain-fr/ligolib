module Types = struct
    type proposal_params = 
    [@layout:comb]
    {
        target_fa12: address;
        target_to: address;
        token_amount: nat;
    }

    type proposal_number = nat

    type t = 
    | Create_proposal of (proposal_params)
    | Sign_proposal of (proposal_number)    
end
