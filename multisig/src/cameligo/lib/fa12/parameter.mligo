module Types = struct 
    type transfer =
    [@layout:comb]
    { [@annot:from] address_from : address;
        [@annot:to] address_to : address;
        value : nat }

    type approve =
    [@layout:comb]
    { spender : address;
        value : nat }

    type allowance_key =
    [@layout:comb]
    { owner : address;
      spender : address }

    type getAllowance =
    [@layout:comb]
    { request : allowance_key;
      callback : nat contract }

    type getBalance =
    [@layout:comb]
    { owner : address;
        callback : nat contract }

    type getTotalSupply =
    [@layout:comb]
    { request : unit ;
        callback : nat contract }

    type t =
    | Transfer of transfer
    | Approve of approve
    | GetAllowance of getAllowance
    | GetBalance of getBalance
    | GetTotalSupply of getTotalSupply
end