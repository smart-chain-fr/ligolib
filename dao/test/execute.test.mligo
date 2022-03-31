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

    let () = Suite_helper.make_proposal_success(tok, dao, Some({
            (* empty operation list *)
            hash = 0xef67ec8260f062258375ab178c485146d467843d2a69b8eae7181441397f4021;
            kind = OperationList;
        })) in
    let () = Time_helper.advance(dao_storage.config.timelock_delay) in

    let r = DAO_helper.execute(1n, 0x0502000000060320053d036d, dao.contr) in
    DAO_helper.assert_executed(dao.taddr, 1n)

(* Successful execution of a parameter change *)
let test_success_parameter_changed = 
    let (tok, dao, sender_) = bootstrap() in
    let dao_storage = Test.get_storage dao.taddr in

    let base_config = DAO_helper.base_config in 
    let packed = Bytes.pack (fun() -> { base_config with quorum_threshold = 51n }) in
    let () = Suite_helper.make_proposal_success(tok, dao, Some({
            (* empty operation list *)
            hash = Crypto.sha256 packed;
            kind = ParameterChange;
        })) in
    let () = Time_helper.advance(dao_storage.config.timelock_delay) in

    let r = DAO_helper.execute(1n, packed, dao.contr) in
    let () = DAO_helper.assert_executed(dao.taddr, 1n) in
    let dao_storage = Test.get_storage dao.taddr in

    (* Assert that the config has been updated *)
    assert(dao_storage.config.quorum_threshold = 51n)

(* Successful execution of an operation list *)
let test_success_operation_list = 
    let (tok, dao, sender_) = bootstrap() in
    let owner1 = List_helper.nth_exn 1 tok.owners in
    let owner2 = List_helper.nth_exn 2 tok.owners in
    let dao_storage = Test.get_storage dao.taddr in

    let packed = Token_helper.pack_transfer(tok.addr, dao.addr, owner2, 2n) in
    let () = Suite_helper.make_proposal_success(tok, dao, Some({
            hash = Crypto.sha256 packed;
            kind = OperationList;
        })) in
    let () = Time_helper.advance(dao_storage.config.timelock_delay) in

    let r = DAO_helper.execute(1n, packed, dao.contr) in
    let () = DAO_helper.assert_executed(dao.taddr, 1n) in
    let tok_storage = Test.get_storage(tok.taddr) in

    (* Assert that the FA2 storage has been changed *)
    let () = (match Big_map.find_opt owner2 tok_storage.ledger with
        Some(amt) -> assert(amt = 10n)
        | None -> failwith("LEDGER_ENTRY_NOT_FOUND")) in
    ()

(* Failing because no outcome *)
let test_failure_no_outcome = 
    let (tok, dao, sender_) = bootstrap() in

    let r = DAO_helper.execute(1n, 0x05030b, dao.contr) in
    Assert.string_failure r DAO.Errors.outcome_not_found

(* Failing because timelock delay not elapsed *)
let test_failure_lambda_wrong_packed_data = 
    let (tok, dao, sender_) = bootstrap() in

    let () = Suite_helper.make_proposal_success(tok, dao, Some({
            hash = 0x01;
            kind = ParameterChange;
        })) in

    let r = DAO_helper.execute(1n, 0x05030b, dao.contr) in
    Assert.string_failure r DAO.Errors.timelock_locked

(* Failing because the packed data is not matching *)
let test_failure_lambda_wrong_packed_data = 
    let (tok, dao, sender_) = bootstrap() in
    let dao_storage = Test.get_storage dao.taddr in

    let () = Suite_helper.make_proposal_success(tok, dao, Some({
            hash = 0x01;
            kind = ParameterChange;
        })) in
    let () = Time_helper.advance(dao_storage.config.timelock_delay) in

    let r = DAO_helper.execute(1n, 0x05030b, dao.contr) in
    Assert.string_failure r DAO.Errors.lambda_wrong_packed_data

(* Failing because the lambda couldn't be unpacked *)
let test_failure_wrong_lambda_kind = 
    let (tok, dao, sender_) = bootstrap() in
    let dao_storage = Test.get_storage dao.taddr in

    let () = Suite_helper.make_proposal_success(tok, dao, Some({
            (* empty operation list *)
            hash = 0xef67ec8260f062258375ab178c485146d467843d2a69b8eae7181441397f4021;
            kind = ParameterChange;
        })) in
    let () = Time_helper.advance(dao_storage.config.timelock_delay) in

    let r = DAO_helper.execute(1n, 0x0502000000060320053d036d, dao.contr) in
    Assert.string_failure r DAO.Errors.wrong_lambda_kind
