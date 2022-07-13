#import "../../src/main.mligo" "Token"

(*
    Get the initial storage of FA2
    init_tok_amount is the amount of token allocated to every owner account
*)
let get_initial_storage (owners, ops, init_tok_amount
: (address * address * address) * (address * address * address) * nat) =
let (owner1, owner2, owner3) = owners in
    let (op1, _op2, op3) = ops in

    let ledger = Big_map.literal ([
        ((owner1, 1n), init_tok_amount);
        ((owner2, 2n), init_tok_amount);
        ((owner3, 3n), init_tok_amount);
        ((owner1, 2n), init_tok_amount);
    ]) in

    let operators  = Big_map.literal ([
        ((owner1, op1), Set.literal [1n; 2n]);
        ((owner2, op1), Set.literal [2n]);
        ((owner3, op1), Set.literal [3n]);
        ((op1   , op3), Set.literal [2n]);
    ]) in

    let token_metadata = (Big_map.literal [
        (1n, ({token_id=1n;token_info=(Map.empty : (string, bytes) map);} : Token.FA2.TokenMetadata.data));
        (2n, ({token_id=2n;token_info=(Map.empty : (string, bytes) map);} : Token.FA2.TokenMetadata.data));
        (3n, ({token_id=3n;token_info=(Map.empty : (string, bytes) map);} : Token.FA2.TokenMetadata.data));
    ] : Token.FA2.TokenMetadata.t) in

    {
        ledger         = ledger;
        token_metadata = token_metadata;
        operators      = operators;
    }
