#import "parameter.mligo" "Parameter"

module Types = struct 
  type tokens = (address, nat) big_map
  type allowances = (Parameter.Types.allowance_key, nat) big_map

  type t = {
    tokens : tokens;
    allowances : allowances;
    total_supply : nat;
  }
end

