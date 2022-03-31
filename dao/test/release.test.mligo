#import "./helpers/token.mligo" "Token_helper"
#import "./helpers/dao.mligo" "DAO_helper"
#import "./helpers/time.mligo" "Time_helper"
#import "./helpers/log.mligo" "Log"
#import "./helpers/assert.mligo" "Assert"
#import "./bootstrap/bootstrap.mligo" "Bootstrap"
#import "../src/main.mligo" "DAO"

let () = Log.describe("[Release] test suite")

(* Boostrapping of the test environment, *)
let init_tok_amount = 10n
let bootstrap () = Bootstrap.boot(init_tok_amount)

(* Successful release *)
let test_success =
    let (tok, dao, sender_) = bootstrap() in

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
    let (tok, dao, sender_) = bootstrap() in
    let r = DAO_helper.release(3n, dao.contr) in
    Assert.string_failure r DAO.Errors.no_locked_tokens

(* Failing release because insuffiscient balance *)
let test_failure_ins_balance = 
    let (tok, dao, sender_) = bootstrap() in
    let () = DAO_helper.lock_success(2n, dao.contr) in
    let r = DAO_helper.release(3n, dao.contr) in
    Assert.string_failure r DAO.Errors.not_enough_balance

(* Failing release because voting is underway *)
let test_failure_voting_period =
    let (tok, dao, sender_) = bootstrap() in
    let dao_storage = Test.get_storage dao.taddr in
    let () = DAO_helper.propose_success(DAO_helper.dummy_proposal, dao.contr) in
    let () = DAO_helper.lock_success(3n, dao.contr) in

    let () = Time_helper.advance(dao_storage.config.start_delay) in
    let r = DAO_helper.release(3n, dao.contr) in

    Assert.string_failure r DAO.Errors.voting_period
