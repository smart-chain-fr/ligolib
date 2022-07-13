#import "tezos-ligo-fa2/test/helpers/list.mligo" "List_helper"
#import "../helpers/token.mligo" "Token_helper"
#import "../helpers/dao.mligo" "DAO_helper"
#import "../../src/main.mligo" "DAO"

(*
    Boostrapping of the test environment,
    init_tok_amount is the amount of token allocated to every
    bootstrapped accounts
*)
let boot (init_tok_amount, init_dao_storage : nat * DAO.storage) =
    (* Originate the token contract and the contract under test *)
    let initial_storage = Token_helper.get_initial_storage(init_tok_amount) in
    let tok = Token_helper.originate(initial_storage) in

    (tok, sender_)
