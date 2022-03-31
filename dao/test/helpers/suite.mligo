#import "./token.mligo" "Token_helper"
#import "./dao.mligo" "DAO_helper"
#import "./time.mligo" "Time_helper"
#import "tezos-ligo-fa2/test/helpers/list.mligo" "List_helper"

(*
    bootstrap proposal and voting process leading to an accepted proposal 
*)
let make_proposal_success(
    tok, dao, lambda_ : Token_helper.originated * DAO_helper.originated * DAO_helper.DAO.Lambda.t option
) =
    let sender_ = List_helper.nth_exn 1 tok.owners in

    (* 
        in order for the proposal to be accepted,
        each token owner locks 25 tokens, 
        so that quorum is reached
    *)
    let amount_ = 25n in
    let () = DAO_helper.batch_lock(tok.owners, amount_, dao.contr) in
    (* restore back bootstrap sender *)
    let () = Test.set_source sender_ in
    let proposal = DAO_helper.dummy_proposal in
    let proposal = { proposal with lambda = lambda_ } in
    let () = DAO_helper.propose_success(proposal, dao.contr) in
    let dao_storage = Test.get_storage dao.taddr in

    (* 
        all voters vote the same, so that super_majority is reached
    *)
    let () = DAO_helper.batch_vote(tok.owners, true, dao.contr) in
    let () = Time_helper.advance(dao_storage.config.start_delay) in
    (* restore back bootstrap sender *)
    let () = Test.set_source sender_ in
    let () = DAO_helper.end_vote_success(dao.contr) in
    ()
