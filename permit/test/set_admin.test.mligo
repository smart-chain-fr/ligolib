#import "./helpers/token.mligo" "Token_helper"
#import "./helpers/log.mligo" "Log"
#import "./helpers/assert.mligo" "Assert"
#import "./bootstrap/bootstrap.mligo" "Bootstrap"
#import "../src/main.mligo" "Token"

let () = Log.describe("[SetAdmin] test suite")

(* Boostrapping of the test environment, *)
let init_tok_amount = 10n
let bootstrap (init_ts, init_default_expiry, init_max_expiry : timestamp * nat * nat) =
    let (admin, owners, owners_with_keys, ops) = Bootstrap.boot_state(init_ts) in
    let base_extended_storage = Token_helper.get_initial_extended_storage(admin, init_default_expiry, init_max_expiry) in
    let tok = Bootstrap.boot_token(owners, ops, init_tok_amount, base_extended_storage) in
    (tok, admin, owners_with_keys)

(* Successful setting of admin *)
let test_success_set_admin =
    let (tok, admin, owners) = bootstrap(("2000-01-01t10:10:10Z" : timestamp), 3600n, 7200n) in
    let (owner1, _, _) = owners in
    let (owner1_addr, _, _) = owner1 in
    let () = Test.set_source admin in
    let () = Token_helper.set_admin_success(owner1_addr, tok.contr) in
    let s = Test.get_storage tok.taddr in
    assert (s.extension.admin = owner1_addr)

(* Failure because sender is not current admin *)
let test_failure_not_admin =
    let (tok,_, owners) = bootstrap(("2000-01-01t10:10:10Z" : timestamp), 3600n, 7200n) in
    let (owner1, _, _) = owners in
    let (owner1_addr, _, _) = owner1 in
    let r = Token_helper.set_admin(owner1_addr, tok.contr) in
    Assert.string_failure r Token.Errors.requires_admin
