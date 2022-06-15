#import "./helpers/token.mligo" "Token_helper"
#import "./helpers/dao.mligo" "DAO_helper"
#import "./helpers/log.mligo" "Log"
#import "./helpers/assert.mligo" "Assert"
#import "./bootstrap/bootstrap.mligo" "Bootstrap"
#import "../src/main.mligo" "DAO"

let () = Log.describe("[Lock] test suite")

(* Boostrapping of the test environment, *)
let init_tok_amount = 10n
let bootstrap (init_dao_storage : DAO.storage) =
    Bootstrap.boot(init_tok_amount, init_dao_storage)
let base_config = DAO_helper.base_config
let base_storage = DAO_helper.base_storage


(* Succesful lock *)
let test_success =
    let (tok, dao, sender_) = bootstrap(base_storage) in

    let amount_ = 3n in
    let r = DAO_helper.lock(amount_, dao.contr) in
    let () = Assert.tx_success r in

    let () = DAO_helper.assert_locked(dao.taddr, sender_, amount_) in
    Token_helper.assert_balance_amount(
        tok.taddr,
        sender_,
        abs(init_tok_amount - amount_))

(* Succesful lock before voting starts *)
let test_success_before_voting_starts =
    (* Add suffiscient start_delay *)
    let config = { base_config with start_delay = 86400n } in
    let dao_storage = { base_storage with config = config } in
    let (tok, dao, sender_) = bootstrap(dao_storage) in
    let dao_storage = Test.get_storage dao.taddr in

    let amount_ = 3n in
    let () = DAO_helper.propose_success(DAO_helper.dummy_proposal, dao.contr) in
    let () = DAO_helper.lock_success(amount_, dao.contr) in

    let () = DAO_helper.assert_locked(dao.taddr, sender_, amount_) in
    Token_helper.assert_balance_amount(
        tok.taddr,
        sender_,
        abs(init_tok_amount - amount_ - dao_storage.config.deposit_amount)
    )

(* Failing lock because sender has insuffiscient balance *)
let test_failure_ins_balance =
    let (tok, dao, sender_) = bootstrap(base_storage) in
    let r = DAO_helper.lock(30n, dao.contr) in
    Token_helper.assert_ins_balance_failure(r)

(* Failing lock because voting is underway *)
let test_failure_voting_period =
    (* Really short start_delay *)
    let config = { base_config with start_delay = 10n } in
    let dao_storage = { base_storage with config = config } in
    let (tok, dao, sender_) = bootstrap(dao_storage) in

    let () = DAO_helper.propose_success(DAO_helper.dummy_proposal, dao.contr) in
    let r = DAO_helper.lock(3n, dao.contr) in

    Assert.string_failure r DAO.Errors.voting_period
