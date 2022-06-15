#import "tezos-ligo-fa2/test/helpers/list.mligo" "List_helper"
#import "./helpers/dao.mligo" "DAO_helper"
#import "./helpers/token.mligo" "Token_helper"
#import "./helpers/suite.mligo" "Suite_helper"
#import "./helpers/log.mligo" "Log"
#import "./helpers/assert.mligo" "Assert"
#import "./bootstrap/bootstrap.mligo" "Bootstrap"
#import "../src/main.mligo" "DAO"

let () = Log.describe("[Cancel] test suite")

(* Boostrapping of the test environment, *)
let init_tok_amount = 33n
let bootstrap (init_dao_storage : DAO.storage) =
    Bootstrap.boot(init_tok_amount, init_dao_storage)
let empty_nat_option = (None: nat option)
let base_config = DAO_helper.base_config
let base_storage = DAO_helper.base_storage


(* Successful cancel of current proposal *)
let test_success_current_proposal =
    let config = { base_config with start_delay = 86400n } in
    let dao_storage = { base_storage with config = config } in
    let (tok, dao, sender_) = bootstrap(dao_storage) in

    let () = DAO_helper.propose_success(DAO_helper.dummy_proposal, dao.contr) in
    let () = DAO_helper.cancel_success(empty_nat_option, dao.contr) in
    let dao_storage = Test.get_storage dao.taddr in
    let () = DAO_helper.assert_proposal_state(dao_storage.outcomes, 1n, Canceled) in
    Token_helper.assert_balance_amount(
        tok.taddr,
        sender_,
        abs(init_tok_amount - dao_storage.config.deposit_amount)
    )

(* Succesful cancel of accepted proposal, before timelock is unlocked *)
let test_success_accepted_proposal =
    let config = { base_config with
        start_delay = 10n;
        voting_period = 1800n;
        timelock_delay = 3000n } in
    let dao_storage = { base_storage with config = config } in
    let (tok, dao, sender_) = bootstrap(dao_storage) in

    let lambda_ = Some(( DAO_helper.empty_op_list_hash, OperationList)) in
    let votes = [(0, 25n, true); (1, 25n, true); (2, 25n, true)] in
    let () = Suite_helper.create_and_vote_proposal(tok, dao, lambda_, votes) in
    let () = DAO_helper.cancel_success(Some(1n), dao.contr) in
    let dao_storage = Test.get_storage dao.taddr in
    DAO_helper.assert_proposal_state(dao_storage.outcomes, 1n, Canceled)

(* Failing cancel because there is nothing to cancel *)
let test_failure_nothing_to_cancel =
    let (tok, dao, sender_) = bootstrap(base_storage) in

    let r = DAO_helper.cancel(empty_nat_option, dao.contr) in
    Assert.string_failure r DAO.Errors.nothing_to_cancel

(* Failing cancel because the outcome was not found *)
let test_failure_outcome_not_found =
    let (tok, dao, sender_) = bootstrap(base_storage) in

    let r = DAO_helper.cancel(Some(23n), dao.contr) in
    Assert.string_failure r DAO.Errors.outcome_not_found

(* Failing cancel proposal because not creator *)
let test_failure_not_creator =
    let config = { base_config with start_delay = 1200n } in
    let dao_storage = { base_storage with config = config } in
    let (tok, dao, sender_) = bootstrap(dao_storage) in
    let () = DAO_helper.propose_success(DAO_helper.dummy_proposal, dao.contr) in

    let sender_ = List_helper.nth_exn 2 tok.owners in
    let () = Test.set_source sender_ in
    let r = DAO_helper.cancel(empty_nat_option, dao.contr) in
    Assert.string_failure r DAO.Errors.not_creator

(* Failing cancel proposal because timelock is unlocked *)
let test_failure_timelock_unlocked =
    let config = { base_config with
        start_delay = 10n;
        voting_period = 1800n; } in
    let dao_storage = { base_storage with config = config } in
    let (tok, dao, sender_) = bootstrap(dao_storage) in

    let lambda_ = Some(( DAO_helper.empty_op_list_hash, OperationList)) in
    let votes = [(0, 25n, true); (1, 25n, true); (2, 25n, true)] in
    let () = Suite_helper.create_and_vote_proposal(tok, dao, lambda_, votes) in

    let r = DAO_helper.cancel(Some(1n), dao.contr) in
    Assert.string_failure r DAO.Errors.timelock_unlocked

(* Failing cancel proposal because it was already executed *)
let test_failure_already_executed =
    let config = { base_config with
        start_delay = 10n;
        voting_period = 1800n; } in
    let dao_storage = { base_storage with config = config } in
    let (tok, dao, sender_) = bootstrap(dao_storage) in

    let lambda_ = Some(( DAO_helper.empty_op_list_hash, OperationList)) in
    let votes = [(0, 25n, true); (1, 25n, true); (2, 25n, true)] in
    let () = Suite_helper.create_and_vote_proposal(tok, dao, lambda_, votes) in
    let () = DAO_helper.execute_success(1n, 0x0502000000060320053d036d, dao.contr) in

    let r = DAO_helper.cancel(Some(1n), dao.contr) in
    Assert.string_failure r DAO.Errors.already_executed
