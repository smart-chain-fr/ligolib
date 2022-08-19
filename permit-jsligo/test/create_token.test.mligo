#import "./helpers/token.mligo" "Token_helper"
#import "./helpers/fa2.mligo" "FA2_helper"
#import "./helpers/log.mligo" "Log"
#import "./helpers/assert.mligo" "Assert"
#import "./bootstrap/bootstrap.mligo" "Bootstrap"
#import "../src/main.jsligo" "Token"

let () = Log.describe("[Create_token] test suite")

(* Boostrapping of the test environment, *)
let init_tok_amount = 10n

let bootstrap () =
    let (admin, owners, owners_with_keys, ops) = Bootstrap.boot_state(Bootstrap.dummy_genesis_ts) in
    let base_extended_storage = Token_helper.get_initial_extended_storage(
      admin, Token_helper.dummy_default_expiry, Token_helper.dummy_max_expiry) in
    let tok = Bootstrap.boot_token(owners, ops, init_tok_amount, base_extended_storage) in
    (tok, admin, owners_with_keys)

(* Successful token creation *)
let test_success =
    let (tok, admin, owners) = bootstrap() in
    let ((owner1_addr, _, _), _, _) = owners in
    let () = Test.set_source admin in
    let token_id = 42n in
    let amount_ = 12n in
    //let () = Token_helper.create_token_success
    let res = Token_helper.create_token
      (FA2_helper.get_dummy_token_data (token_id),
       owner1_addr, amount_, tok.contr) in
    let () = Test.log(res) in   
    let s = Test.get_storage tok.taddr in
    let () = Test.log(s) in
    let () = Token_helper.assert_balance(tok.taddr, owner1_addr, token_id, amount_) in
    Token_helper.assert_supply(tok.taddr, token_id, amount_)

(* Failure because token id already present *)
let test_failure_token_exist =
    let (tok, admin, owners) = bootstrap() in
    let ((owner1_addr, _, _), _, _) = owners in
    let () = Test.set_source admin in
    let r = Token_helper.create_token
      (FA2_helper.get_dummy_token_data (1n),
       owner1_addr, 12n, tok.contr) in
    Assert.string_failure r Token.Errors.token_exist

(* Failure because sender is not current admin *)
let test_failure_not_admin =
    let (tok, _, owners) = bootstrap() in
    let ((owner1_addr, _, _), _, _) = owners in
    let () = Test.set_source owner1_addr in
    let r = Token_helper.create_token
      (FA2_helper.get_dummy_token_data (42n),
       owner1_addr, 12n, tok.contr) in
    Assert.string_failure r Token.Errors.requires_admin
