#import "tezos-ligo-fa2/test/helpers/list.mligo" "List_helper"
#import "./helpers/token.mligo" "Token_helper"
#import "./helpers/dao.mligo" "DAO_helper"
#import "./helpers/suite.mligo" "Suite_helper"
#import "./helpers/log.mligo" "Log"
#import "./helpers/time.mligo" "Time_helper"
#import "./helpers/assert.mligo" "Assert"
#import "./bootstrap/bootstrap.mligo" "Bootstrap"
#import "../src/main.mligo" "DAO"

let () = Log.describe("[Execute] test suite")

(* Boostrapping of the test environment, *)
let init_tok_amount = 33n
let bootstrap () = Bootstrap.boot(init_tok_amount)

(* Successful timelock execution of an operation list *)
let test_success =
    let (tok, dao, sender_) = bootstrap() in
    let dao_storage = Test.get_storage dao.taddr in

    let lambda_ = Some(( DAO_helper.empty_op_list_hash, OperationList)) in
    let votes = [(0, 25n, true); (1, 25n, true); (2, 25n, true)] in
    let () = Suite_helper.create_and_vote_proposal(tok, dao, lambda_, votes) in
    let () = Time_helper.advance(dao_storage.config.timelock_delay) in

    let r = DAO_helper.execute(1n, DAO_helper.empty_op_list_packed, dao.contr) in
    DAO_helper.assert_executed(dao.taddr, 1n)

(* Successful execution of a parameter change *)
let test_success_parameter_changed =
    let (tok, dao, sender_) = bootstrap() in
    let dao_storage = Test.get_storage dao.taddr in

    let base_config = DAO_helper.base_config in
    let packed = Bytes.pack (fun() -> { base_config with quorum_threshold = 51n }) in
    let lambda_ = Some((Crypto.sha256 packed, ParameterChange)) in
    let votes = [(0, 25n, true); (1, 25n, true); (2, 25n, true)] in
    let () = Suite_helper.create_and_vote_proposal(tok, dao, lambda_, votes) in
    let () = Time_helper.advance(dao_storage.config.timelock_delay) in

    let r = DAO_helper.execute(1n, packed, dao.contr) in
    let () = DAO_helper.assert_executed(dao.taddr, 1n) in
    let dao_storage = Test.get_storage dao.taddr in

    (* Assert that the config has been updated *)
    assert(dao_storage.config.quorum_threshold = 51n)

(* Successful execution of an operation list *)
let test_success_operation_list =
    let (tok, dao, sender_) = bootstrap() in
    let owner2 = List_helper.nth_exn 2 tok.owners in
    let dao_storage = Test.get_storage dao.taddr in
    let owner2_initial_balance = Token_helper.get_balance_for(tok.taddr, owner2) in

    (* Pack an operation that will send 2 tokens from DAO to owner2 *)
    let owner2_amount_to_receive = 2n in
    let packed = Token_helper.pack_transfer(tok.addr, dao.addr, owner2,
    owner2_amount_to_receive) in

    let owner2_amount_locked = 25n in
    let lambda_ = Some((Crypto.sha256 packed, OperationList)) in
    let votes = [(0, 25n, true); (1, 25n, true); (2, owner2_amount_locked, true)] in
    let () = Suite_helper.create_and_vote_proposal(tok, dao, lambda_, votes) in
    let () = Time_helper.advance(dao_storage.config.timelock_delay) in

    let r = DAO_helper.execute(1n, packed, dao.contr) in
    let () = DAO_helper.assert_executed(dao.taddr, 1n) in

    let owner2_expected_balance : nat = abs(
        owner2_initial_balance
        - owner2_amount_locked
        + owner2_amount_to_receive)
    in
    Token_helper.assert_balance_amount(tok.taddr, owner2, owner2_expected_balance)

(* Failing because no outcome *)
let test_failure_no_outcome =
    let (tok, dao, sender_) = bootstrap() in

    let r = DAO_helper.execute(1n, DAO_helper.dummy_packed, dao.contr) in
    Assert.string_failure r DAO.Errors.outcome_not_found

(* Failing because timelock delay not elapsed *)
let test_failure_timelock_delay_not_elapsed =
    let (tok, dao, sender_) = bootstrap() in

    let lambda_ = Some((DAO_helper.dummy_hash, ParameterChange)) in
    let votes = [(0, 25n, true); (1, 25n, true); (2, 25n, true)] in
    let () = Suite_helper.create_and_vote_proposal(tok, dao, lambda_, votes) in

    let r = DAO_helper.execute(1n, DAO_helper.dummy_packed, dao.contr) in
    Assert.string_failure r DAO.Errors.timelock_locked

(* Failing because timelock has been relocked *)
let test_failure_timelock_relocked =
    let (tok, dao, sender_) = bootstrap() in
    let dao_storage = Test.get_storage dao.taddr in

    let lambda_ = Some(( DAO_helper.empty_op_list_hash, OperationList)) in
    let votes = [(0, 25n, true); (1, 25n, true); (2, 25n, true)] in
    let () = Suite_helper.create_and_vote_proposal(tok, dao, lambda_, votes) in

    let time_elapsed : nat = dao_storage.config.timelock_delay + dao_storage.config.timelock_period in
    let () = Time_helper.advance(time_elapsed) in

    let r = DAO_helper.execute(1n, DAO_helper.empty_op_list_packed, dao.contr) in
    Assert.string_failure r DAO.Errors.timelock_locked

(* Failing because the packed data is not matching *)
let test_failure_lambda_wrong_packed_data =
    let (tok, dao, sender_) = bootstrap() in
    let dao_storage = Test.get_storage dao.taddr in

    let lambda_ = Some((DAO_helper.dummy_hash, ParameterChange)) in
    let votes = [(0, 25n, true); (1, 25n, true); (2, 25n, true)] in
    let () = Suite_helper.create_and_vote_proposal(tok, dao, lambda_, votes) in
    let () = Time_helper.advance(dao_storage.config.timelock_delay) in

    let r = DAO_helper.execute(1n, DAO_helper.dummy_packed, dao.contr) in
    Assert.string_failure r DAO.Errors.lambda_wrong_packed_data

(* Failing because the lambda couldn't be unpacked because of wrong lambda kind *)
let test_failure_wrong_lambda_kind =
    let (tok, dao, sender_) = bootstrap() in
    let dao_storage = Test.get_storage dao.taddr in

    (* the lambda kind is ParameterChange but it should have been OperationList *)
    let lambda_ = Some( (DAO_helper.empty_op_list_hash, ParameterChange)) in
    let votes = [(0, 25n, true); (1, 25n, true); (2, 25n, true)] in
    let () = Suite_helper.create_and_vote_proposal(tok, dao, lambda_, votes) in
    let () = Time_helper.advance(dao_storage.config.timelock_delay) in

    let r = DAO_helper.execute(1n, DAO_helper.empty_op_list_packed, dao.contr) in
    Assert.string_failure r DAO.Errors.wrong_lambda_kind
