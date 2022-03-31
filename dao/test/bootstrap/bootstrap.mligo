#import "tezos-ligo-fa2/test/helpers/list.mligo" "List_helper"
#import "../helpers/token.mligo" "Token_helper"
#import "../helpers/dao.mligo" "DAO_helper"

(* 
    Boostrapping of the test environment, 
    init_tok_amount is the amount of token allocated to every
    bootstrapped accounts
*)
let boot (init_tok_amount : nat) = 
    (* Originate the token contract and the contract under test *)
    let tok = Token_helper.originate(init_tok_amount) in
    let dao = DAO_helper.originate(DAO_helper.base_storage(tok.addr)) in

    (* Add the dao as operator for all the FA2 owner addresses
        TODO: ... in the real world, remove operator? *)
    let () = List.iter (fun (owner: address) -> 
        let () = Test.set_source owner in
        Token_helper.add_operators(
            [{ owner = owner; operator = dao.addr; token_id = 0n } ],
            tok.contr
        )) tok.owners in

    (* Set a token owner as sender in the Test framework *)
    let sender_ = List_helper.nth_exn 1 tok.owners in
    let () = Test.set_source sender_ in

    (tok, dao, sender_)
