#import "./helpers/token.mligo" "Token_helper"
#import "./helpers/fa2.mligo" "FA2_helper"
#import "./helpers/log.mligo" "Log"
#import "./helpers/assert.mligo" "Assert"
#import "./bootstrap/bootstrap.mligo" "Bootstrap"
#import "../src/main.jsligo" "Token"

let () = Log.describe("[Burn_token] test suite")

(* Boostrapping of the test environment, *)
let init_tok_amount = 10n

let bootstrap () =
    let (admin, owners, owners_with_keys, ops) = Bootstrap.boot_state(Bootstrap.dummy_genesis_ts) in
    let base_extended_storage = Token_helper.get_initial_extended_storage(
      admin, Token_helper.dummy_default_expiry, Token_helper.dummy_max_expiry) in
    let tok = Bootstrap.boot_token(owners, ops, init_tok_amount, base_extended_storage) in
    (tok, admin, owners_with_keys)

(* Successful token mint *)
let test_success =
    let (tok, admin, owners) = bootstrap() in
    let ((owner1_addr, _, _), _, _) = owners in
    let () = Test.set_source admin in
    let token_id = 1n in
    let amount_ = 6n in
    let () = Token_helper.burn_token_success([{
       owner=owner1_addr;
       token_id=token_id;
       amount_=amount_;
    }], tok.contr) in
    let new_amount =  abs(init_tok_amount - amount_) in
    let () = Token_helper.assert_balance(tok.taddr, owner1_addr, token_id, new_amount) in
    Token_helper.assert_supply(tok.taddr, token_id, new_amount)

(* Failure because sender is not current admin *)
let test_failure_not_admin =
    let (tok, _, owners) = bootstrap() in
    let ((owner1_addr, _, _), _, _) = owners in
    let () = Test.set_source owner1_addr in
    let r = Token_helper.burn_token([{
       owner=owner1_addr;
       token_id=1n;
       amount_=1n;
    }], tok.contr) in
    Assert.string_failure r Token.Errors.requires_admin
