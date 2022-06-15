#import "./helpers/token.mligo" "Token_helper"
#import "./helpers/dao.mligo" "DAO_helper"
#import "./helpers/log.mligo" "Log"
#import "./helpers/assert.mligo" "Assert"
#import "./bootstrap/bootstrap.mligo" "Bootstrap"
#import "../src/main.mligo" "DAO"

let () = Log.describe("[Release] test suite")

(* Boostrapping of the test environment, *)
let init_tok_amount = 10n
let bootstrap (init_dao_storage : DAO.storage) =
    Bootstrap.boot(init_tok_amount, init_dao_storage)
let base_config = DAO_helper.base_config
let base_storage = DAO_helper.base_storage

(* Successful release *)
let test_success =
    let (tok, dao, sender_) = bootstrap(base_storage) in

    let () = DAO_helper.lock_success(3n, dao.contr) in
    let () = DAO_helper.release_success(3n, dao.contr) in

    let () = DAO_helper.assert_locked(dao.taddr, sender_, 0n) in
    Token_helper.assert_balance_amount(
        tok.taddr,
        sender_,
        init_tok_amount
    )

(* Failing release because no locked tokens *)
let test_failure_ins_balance =
    let (tok, dao, sender_) = bootstrap(base_storage) in
    let r = DAO_helper.release(3n, dao.contr) in
    Assert.string_failure r DAO.Errors.no_locked_tokens

(* Failing release because insuffiscient balance *)
let test_failure_ins_balance =
    let (tok, dao, sender_) = bootstrap(base_storage) in
    let () = DAO_helper.lock_success(2n, dao.contr) in
    let r = DAO_helper.release(3n, dao.contr) in
    Assert.string_failure r DAO.Errors.not_enough_balance

(* Failing release because voting is underway *)
let test_failure_voting_period =
    (* Really short start_delay *)
    let config = { base_config with start_delay = 10n } in
    let dao_storage = { base_storage with config = config } in
    let (tok, dao, sender_) = bootstrap(dao_storage) in

    let () = DAO_helper.lock_success(3n, dao.contr) in
    let () = DAO_helper.propose_success(DAO_helper.dummy_proposal, dao.contr) in

    let r = DAO_helper.release(3n, dao.contr) in

    Assert.string_failure r DAO.Errors.voting_period
