#import "tezos-ligo-fa2/test/helpers/list.mligo" "List_helper"
#import "./helpers/dao.mligo" "DAO_helper"
#import "./helpers/time.mligo" "Time_helper"
#import "./helpers/suite.mligo" "Suite_helper"
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

    let lambda_ = Some(( DAO_helper.empty_op_list_hash, OperationList)) in
    let votes = [(0, 25n, true); (1, 25n, true); (2, 25n, true)] in
    let () = Suite_helper.create_and_vote_proposal(tok, dao, lambda_, votes) in
    let dao_storage = Test.get_storage dao.taddr in
    let () = assert (dao_storage.proposal = (None: DAO.Proposal.t option)) in
    DAO_helper.assert_proposal_state(dao_storage.outcomes, 1n, Accepted)

(* Successful end_vote with proposal rejected because quorum was not reached *)
let test_success_prop_rejected_quorum_not_reached =
    let (tok, dao, sender_) = bootstrap() in

    let lambda_ = (None: DAO.Lambda.t option) in
    let votes = [(0, 5n, true); (1, 5n, true); (2, 5n, true)] in
    let () = Suite_helper.create_and_vote_proposal(tok, dao, lambda_, votes) in

    let dao_storage = Test.get_storage dao.taddr in
    DAO_helper.assert_proposal_state(dao_storage.outcomes, 1n, Rejected_(WithoutRefund))

(* Successful end_vote with proposal rejected because super_majority was not reached *)
let test_success_prop_rejected_super_maj_not_reached =
    let (tok, dao, sender_) = bootstrap() in

    let lambda_ = (None: DAO.Lambda.t option) in
    let votes = [(0, 15n, true); (1, 15n, true); (2, 15n, false)] in
    let () = Suite_helper.create_and_vote_proposal(tok, dao, lambda_, votes) in
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
