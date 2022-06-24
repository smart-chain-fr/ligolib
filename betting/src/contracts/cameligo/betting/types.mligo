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

type ledger = (address, nat) big_map

type allowances = (allowance_key, nat) big_map

type token_metadata_entry = {
  token_id: nat;
  token_info: (string, bytes) map;
}

type storage =
  [@layout:comb]
  { ledger : ledger;
    allowances : allowances;
    admin : address;
    reserve : address;
    burn_address : address;
    initial_supply : nat;
    total_supply : nat;
    burned_supply : nat;
    metadata: (string, bytes) big_map;
    token_metadata : (nat, token_metadata_entry) big_map
  }

type parameter =
  | Transfer of transfer
  | Approve of approve
  | GetAllowance of getAllowance
  | GetBalance of getBalance
  | GetTotalSupply of getTotalSupply

type result = operation list * storage