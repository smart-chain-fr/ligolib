#import "./helpers/dao.mligo" "DAO_helper"
#import "./helpers/time.mligo" "Time_helper"
#import "./helpers/log.mligo" "Log"
#import "./helpers/assert.mligo" "Assert"
#import "./bootstrap/bootstrap.mligo" "Bootstrap"
#import "../src/main.mligo" "DAO"

let () = Log.describe("[Vote] test suite")

(* Boostrapping of the test environment, *)
let init_tok_amount = 10n
let bootstrap () = Bootstrap.boot(init_tok_amount)

(* Successful vote *)
let test_success =
    let (tok, dao, sender_) = bootstrap() in
    let dao_storage = Test.get_storage dao.taddr in

    let amount_ = 3n in
    let () = DAO_helper.lock_success(amount_, dao.contr) in
    let () = DAO_helper.propose_success(DAO_helper.dummy_proposal, dao.contr) in
    let () = Time_helper.advance(dao_storage.config.start_delay * 2n) in

    let choice = true in
    let r = DAO_helper.vote_success(choice, dao.contr) in
    DAO_helper.assert_voted(dao.taddr, sender_, choice, amount_)

(* Failing vote because no proposal *)
let test_failure_no_proposal =
    let (tok, dao, sender_) = bootstrap() in

    let r = DAO_helper.vote(true, dao.contr) in
    Assert.string_failure r DAO.Errors.no_proposal

(* Failing vote because proposal is not in voting period *)
let test_failure_not_voting_period =
    let (tok, dao, sender_) = bootstrap() in

    let amount_ = 3n in
    let () = DAO_helper.lock_success(amount_, dao.contr) in
    let () = DAO_helper.propose_success(DAO_helper.dummy_proposal, dao.contr) in

    let r = DAO_helper.vote(true, dao.contr) in
    Assert.string_failure r DAO.Errors.not_voting_period

(* Failing because no locked tokens in vault *)
let test_failure_no_locked_tokens =
    let (tok, dao, sender_) = bootstrap() in
    let dao_storage = Test.get_storage dao.taddr in

    let amount_ = 3n in
    let () = DAO_helper.propose_success(DAO_helper.dummy_proposal, dao.contr) in
    let () = Time_helper.advance(dao_storage.config.start_delay * 2n) in

    let choice = true in
    let r = DAO_helper.vote(true, dao.contr) in
    Assert.string_failure r DAO.Errors.no_locked_tokens
