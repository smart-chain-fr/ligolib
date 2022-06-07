#import "./helpers/token.mligo" "Token_helper"
#import "./helpers/dao.mligo" "DAO_helper"
#import "./helpers/log.mligo" "Log"
#import "./helpers/assert.mligo" "Assert"
#import "./bootstrap/bootstrap.mligo" "Bootstrap"
#import "../src/main.mligo" "DAO"

let () = Log.describe("[Propose] test suite")

(* Boostrapping of the test environment, *)
let init_tok_amount = 10n
let bootstrap () = Bootstrap.boot(init_tok_amount, DAO_helper.base_storage)

(* Successful proposal creation *)
let test_success =
    let (tok, dao, sender_) = bootstrap() in

    let r = DAO_helper.propose(DAO_helper.dummy_proposal, dao.contr) in
    let () = Assert.tx_success r in

    let dao_storage = Test.get_storage dao.taddr in
    let proposal = Option.unopt(dao_storage.proposal) in
    let lambda_ = Option.unopt(proposal.lambda) in
    let () = assert(proposal.creator = sender_) in
    let () = assert(proposal.description_link = "ipfs://QmbKq7QriWWU74NSq35sDSgUf24bYWTgpBq3Lea7A3d7jU") in
    let (hash_, kind) = lambda_ in
    let () = assert(hash_ = 0x01) in
    let () = assert(kind = ParameterChange) in

    let () = Token_helper.assert_balance_amount(tok.taddr, dao.addr, dao_storage.config.deposit_amount) in
    Token_helper.assert_balance_amount(
        tok.taddr,
        sender_,
        abs(init_tok_amount - dao_storage.config.deposit_amount)
    )

(* Failing proposal creation because there is already a proposal *)
let test_failure_proposal_exists =
    let (tok, dao, sender_) = bootstrap() in

    let () = DAO_helper.propose_success(DAO_helper.dummy_proposal, dao.contr) in
    let r = DAO_helper.propose(DAO_helper.dummy_proposal, dao.contr) in

    Assert.string_failure r DAO.Errors.proposal_already_exists

(* Failing because the proposing account doesn't have sufiscient balance for the deposit amount *)
let test_failure_insufiscient_balance =
    let (tok, dao, sender_) = bootstrap() in

    (* Burn all the sender tokens *)
    let burn_addr = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg": address) in
    let _ = Token_helper.transfer(tok.contr, sender_, burn_addr, init_tok_amount) in
    let r = DAO_helper.propose(DAO_helper.dummy_proposal, dao.contr) in

    Token_helper.assert_ins_balance_failure(r)
