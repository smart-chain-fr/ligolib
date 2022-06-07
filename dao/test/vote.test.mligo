#import "./helpers/dao.mligo" "DAO_helper"
#import "./helpers/log.mligo" "Log"
#import "./helpers/assert.mligo" "Assert"
#import "./bootstrap/bootstrap.mligo" "Bootstrap"
#import "../src/main.mligo" "DAO"

let () = Log.describe("[Vote] test suite")

(* Boostrapping of the test environment, *)
let init_tok_amount = 10n
let bootstrap (init_dao_storage : DAO.storage) =
    Bootstrap.boot(init_tok_amount, init_dao_storage)
let base_config = DAO_helper.base_config
let base_storage = DAO_helper.base_storage

(* Successful vote *)
let test_success =
    let config = { base_config with start_delay = 10n } in
    let dao_storage = { base_storage with config = config } in
    let (tok, dao, sender_) = bootstrap(dao_storage) in

    let amount_ = 3n in
    let () = DAO_helper.lock_success(amount_, dao.contr) in
    let () = DAO_helper.propose_success(DAO_helper.dummy_proposal, dao.contr) in

    let choice = true in
    let r = DAO_helper.vote_success(choice, dao.contr) in
    DAO_helper.assert_voted(dao.taddr, sender_, choice, amount_)

(* Failing vote because no proposal *)
let test_failure_no_proposal =
    let (tok, dao, sender_) = bootstrap(base_storage) in

    let r = DAO_helper.vote(true, dao.contr) in
    Assert.string_failure r DAO.Errors.no_proposal

(* Failing vote because proposal is not in voting period *)
let test_failure_not_voting_period =
    let (tok, dao, sender_) = bootstrap(base_storage) in

    let amount_ = 3n in
    let () = DAO_helper.lock_success(amount_, dao.contr) in
    let () = DAO_helper.propose_success(DAO_helper.dummy_proposal, dao.contr) in

    let r = DAO_helper.vote(true, dao.contr) in
    Assert.string_failure r DAO.Errors.not_voting_period

(* Failing because no locked tokens in vault *)
let test_failure_no_locked_tokens =
    (* Really short start_delay *)
    let config = { base_config with start_delay = 10n } in
    let dao_storage = { base_storage with config = config } in
    let (tok, dao, sender_) = bootstrap(dao_storage) in

    let amount_ = 3n in
    let () = DAO_helper.propose_success(DAO_helper.dummy_proposal, dao.contr) in

    let choice = true in
    let r = DAO_helper.vote(true, dao.contr) in
    Assert.string_failure r DAO.Errors.no_locked_tokens
