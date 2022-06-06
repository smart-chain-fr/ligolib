#import "./token.mligo" "Token_helper"
#import "./dao.mligo" "DAO_helper"
#import "./time.mligo" "Time_helper"
#import "tezos-ligo-fa2/test/helpers/list.mligo" "List_helper"

(*
    Creates a proposal on [dao] with [tok] as governance_token,
    using given [lambda_] for the proposal lambda.
    The proposal creator is the first token owner registered in
    the given [tok] token contract owners list.
    Every token owner locks [amount_] of tokens in the DAO,
    and votes "yes" to the created proposal,
    eventually, the end_vote entry point is called.
    Can lead to either accepted or rejected proposal, according to
    the given [amount_] of tokens
*)
let create_and_vote_proposal (
    tok, dao, lambda_, votes : Token_helper.originated *
    DAO_helper.originated * DAO_helper.DAO.Lambda.t option * (int * nat * bool)
    list
) =
    (* set up the sender for propose and end_vote entry points *)
    let sender_ = List_helper.nth_exn 1 tok.owners in

    (* impersonate token owners and call lock entry point *)
    let do_lock (nth_account, amount_, _ : int * nat * bool) =
        let () = Test.set_source (List_helper.nth_exn nth_account tok.owners) in
        DAO_helper.lock_success(amount_, dao.contr)
    in
    let () = List.iter do_lock votes in

    (* create proposal *)
    let () = Test.set_source sender_ in
    let proposal = DAO_helper.dummy_proposal in
    let proposal = { proposal with lambda = lambda_ } in
    let () = DAO_helper.propose_success(proposal, dao.contr) in

    (* impersonate token owners and call vote entry point *)
    let do_vote (nth_account, _, choice : int * nat * bool) =
        let () = Test.set_source (List_helper.nth_exn nth_account tok.owners) in
        DAO_helper.vote_success(choice, dao.contr)
    in
    let () = List.iter do_vote votes in

    (* advance suffiscient time for the voting period to elapse, and call end_vote
       entry point *)
    let dao_storage = Test.get_storage dao.taddr in
    let () = Time_helper.advance(dao_storage.config.start_delay) in
    let () = Test.set_source sender_ in
    let () = DAO_helper.end_vote_success(dao.contr) in
    ()
