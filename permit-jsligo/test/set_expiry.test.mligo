#import "./helpers/token.mligo" "Token_helper"
#import "./helpers/log.mligo" "Log"
#import "./helpers/assert.mligo" "Assert"
#import "./bootstrap/bootstrap.mligo" "Bootstrap"
#import "../src/main.jsligo" "Token"

let () = Log.describe("[SetExpiry] test suite")

(* Boostrapping of the test environment, *)
let init_tok_amount = 10n
let bootstrap (init_ts, init_default_expiry, init_max_expiry : timestamp * nat * nat) =
    let (admin, owners, owners_with_keys, ops) = Bootstrap.boot_state(init_ts) in
    let base_extended_storage = Token_helper.get_initial_extended_storage(admin, init_default_expiry, init_max_expiry) in
    let tok = Bootstrap.boot_token(owners, ops, init_tok_amount, base_extended_storage) in
    (tok, admin, owners_with_keys)

(* Successful setting of user expiry *)
let test_success_set_user_expiry =
    let (tok, _, owners) = bootstrap(("2000-01-01t10:10:10Z" : timestamp), 3600n, 7200n) in
    let (owner1, _, _) = owners in
    let (owner1_addr, _, _) = owner1 in
    let () = Test.set_source owner1_addr in
    let expiry_params : Token.expiry_params = (owner1_addr, (5400n, (None: bytes option))) in
    let () = Token_helper.set_expiry_success(expiry_params, tok.contr) in
    Token_helper.assert_user_expiry(tok.taddr, owner1_addr, Some(5400n))

(* Successful setting of permit expiry *)
let test_success_set_permit_expiry =
    let (tok, _, owners) = bootstrap(("2000-01-01t10:10:10Z" : timestamp), 3600n, 7200n) in
    let (owner1, _, _) = owners in
    let (owner1_addr, _, _) = owner1 in
    let () = Test.set_source owner1_addr in
    let hash_ = 0x01 in
    let expiry_params : Token.expiry_params = (owner1_addr, (5400n, (Some(hash_)))) in
    let () = Token_helper.set_expiry_success(expiry_params, tok.contr) in
    Token_helper.assert_permit_expiry(tok.taddr, owner1_addr, hash_, Some(5400n))

(* Failure because sender is not the updated user expiry *)
let test_failure_forbidden =
    let (tok, _, owners) = bootstrap(("2000-01-01t10:10:10Z" : timestamp), 3600n, 7200n) in
    let (owner1, owner2, _) = owners in
    let (owner1_addr, _, _) = owner1 in
    let (owner2_addr, _, _) = owner2 in
    let () = Test.set_source owner2_addr in
    let expiry_params : Token.expiry_params = (owner1_addr, (5400n, (None: bytes option))) in
    let r = Token_helper.set_expiry(expiry_params, tok.contr) in
    Assert.string_failure r Token.Errors.forbidden_expiry_update

(* Failure because tried to set value exceeding max_expiry *)
let test_failure_max_seconds_exceeded =
    let (tok, _, owners) = bootstrap(("2000-01-01t10:10:10Z" : timestamp), 3600n, 7200n) in
    let (owner1, owner2, _) = owners in
    let (owner1_addr, _, _) = owner1 in
    let (owner2_addr, _, _) = owner2 in
    let () = Test.set_source owner2_addr in
    let expiry_params : Token.expiry_params = (owner1_addr, (14_400n, (None: bytes option))) in
    let r = Token_helper.set_expiry(expiry_params, tok.contr) in
    Assert.string_failure r Token.Errors.max_seconds_exceeded


