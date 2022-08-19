#import "../../src/main.jsligo" "Token"

let dummy_token_info = (Map.empty : (string, bytes) map)

let get_dummy_token_data (token_id : nat) : Token.FA2.TokenMetadata.data =
   {token_id=token_id;token_info=dummy_token_info}

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
        (1n, get_dummy_token_data(1n));
        (2n, get_dummy_token_data(2n));
        (3n, get_dummy_token_data(3n));
    ] : Token.FA2.TokenMetadata.t) in

    {
        ledger         = ledger;
        token_metadata = token_metadata;
        operators      = operators;
    }
