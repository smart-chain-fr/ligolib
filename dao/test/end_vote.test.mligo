#import "tezos-ligo-fa2/test/helpers/list.mligo" "List_helper"
#import "./helpers/dao.mligo" "DAO_helper"
#import "./helpers/time.mligo" "Time_helper"
#import "./helpers/log.mligo" "Log"
#import "./helpers/assert.mligo" "Assert"
#import "./bootstrap/bootstrap.mligo" "Bootstrap"
#import "../src/main.mligo" "DAO"

let () = Log.describe("[End_vote] test suite")

(* Boostrapping of the test environment, *)
let init_tok_amount = 33n
let bootstrap () = Bootstrap.boot(init_tok_amount)

(* Successful end_vote with proposal accepted *)
let test_success_prop_accepted = 
    let (tok, dao, sender_) = bootstrap() in

    (* 
        in order for this test to be succesful,
        each token owner locks 25 tokens, 
        so that quorum is reached
    *)
    let amount_ = 25n in
    let () = DAO_helper.batch_lock(tok.owners, amount_, dao.contr) in
    (* restore back bootstrap sender *)
    let () = Test.set_source sender_ in
    let () = DAO_helper.propose_success(DAO_helper.dummy_proposal, dao.contr) in
    let dao_storage = Test.get_storage dao.taddr in

    (* 
        all voters vote the same, so that super_majority is reached
    *)
    let () = DAO_helper.batch_vote(tok.owners, true, dao.contr) in
    let () = Time_helper.advance(dao_storage.config.start_delay) in
    (* restore back bootstrap sender *)
    let () = Test.set_source sender_ in
    let () = DAO_helper.end_vote_success(dao.contr) in
    let dao_storage = Test.get_storage dao.taddr in
    let () = assert (dao_storage.proposal = (None: DAO.Proposal.t option)) in
    DAO_helper.assert_proposal_state(dao_storage.outcomes, 1n, Accepted)

(* Successful end_vote with proposal rejected because quorum was not reached *)
let test_success_prop_rejected_quorum_not_reached = 
    let (tok, dao, sender_) = bootstrap() in

    (* 
        in order for this test to be succesful,
        each token owner locks 5 tokens, 
        so that quorum is not reached
    *)
    let amount_ = 5n in
    let () = DAO_helper.batch_lock(tok.owners, amount_, dao.contr) in
    (* restore back bootstrap sender *)
    let () = Test.set_source sender_ in
    let () = DAO_helper.propose_success(DAO_helper.dummy_proposal, dao.contr) in
    let dao_storage = Test.get_storage dao.taddr in

    (* 
        all voters vote the same, so that super_majority is reached
    *)
    let () = DAO_helper.batch_vote(tok.owners, true, dao.contr) in
    let () = Time_helper.advance(dao_storage.config.start_delay) in
    (* restore back bootstrap sender *)
    let () = Test.set_source sender_ in
    let () = DAO_helper.end_vote_success(dao.contr) in
    let dao_storage = Test.get_storage dao.taddr in
    DAO_helper.assert_proposal_state(dao_storage.outcomes, 1n, Rejected_(WithoutRefund))

(* Successful end_vote with proposal rejected because super_majority was not reached *)
let test_success_prop_rejected_sm_not_reached = 
    let (tok, dao, sender_) = bootstrap() in

    (* 
        in order for this test to be succesful,
        each token owner locks 25 tokens, 
        so that quorum is reached
    *)
    let amount_ = 25n in
    let () = DAO_helper.batch_lock(tok.owners, amount_, dao.contr) in
    (* restore back bootstrap sender *)
    let () = Test.set_source sender_ in
    let () = DAO_helper.propose_success(DAO_helper.dummy_proposal, dao.contr) in
    let dao_storage = Test.get_storage dao.taddr in

    (* some voters vote "yes" *)
    let () = DAO_helper.batch_vote([
        List_helper.nth_exn 0 tok.owners;
        List_helper.nth_exn 1 tok.owners
    ], true, dao.contr) in
    (* one votes "no" *)
    let () = Test.set_source (List_helper.nth_exn 2 tok.owners) in
    let () = DAO_helper.vote_success(false, dao.contr) in
    (* restore back bootstrap sender *)
    let () = Test.set_source sender_ in
    let () = Time_helper.advance(dao_storage.config.start_delay) in
    let () = DAO_helper.end_vote_success(dao.contr) in
    let dao_storage = Test.get_storage dao.taddr in
    DAO_helper.assert_proposal_state(dao_storage.outcomes, 1n, Rejected_(WithRefund))

(* Failing end_vote because proposal voting period ongoing *)
let test_failure_voting_period = 
    let (tok, dao, sender_) = bootstrap() in
    let dao_storage = Test.get_storage dao.taddr in

    let () = DAO_helper.propose_success(DAO_helper.dummy_proposal, dao.contr) in

    let () = Time_helper.advance(dao_storage.config.start_delay * 2n) in
    let r = DAO_helper.end_vote(dao.contr) in
    Assert.string_failure r DAO.Errors.voting_period

(* TODO: test for total_supply_not_found error *)
