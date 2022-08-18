#import "./helpers/token.mligo" "Token_helper"
#import "./helpers/log.mligo" "Log"
#import "./helpers/assert.mligo" "Assert"
#import "./bootstrap/bootstrap.mligo" "Bootstrap"
#import "../src/main.mligo" "Token"

let () = Log.describe("[Transfer] test suite")

(* Boostrapping of the test environment, *)
let init_tok_amount = 10n
let bootstrap (init_ts, init_default_expiry, init_max_expiry : timestamp * nat * nat) =
    let (admin, owners, owners_with_keys, ops) = Bootstrap.boot_state(init_ts) in
    let base_extended_storage = Token_helper.get_initial_extended_storage(admin, init_default_expiry, init_max_expiry) in
    let tok = Bootstrap.boot_token(owners, ops, init_tok_amount, base_extended_storage) in
    (tok, admin, owners_with_keys)

(* Successful transfer with permit *)
let test_success =
    let (tok, _, owners) = bootstrap(("2000-01-01t10:10:10Z" : timestamp), 3600n, 7200n) in
    let (owner1, owner2, _) = owners in
    let (owner1_addr, _, _) = owner1 in
    let (owner2_addr, _, _) = owner2 in
    let transfer_request = ({
        from_=owner1_addr;
        tx=([{to_=owner2_addr;amount=2n;token_id=1n}] : Token.FA2.atomic_trans list)
    }) in
    let hash_ = Crypto.blake2b (Bytes.pack transfer_request) in
    let permit = Token_helper.make_permit(hash_, owner1, tok.addr, 0n) in
    let () = Token_helper.permit_success([permit], tok.contr) in
    let transfer_requests = ([transfer_request] : Token.FA2.transfer) in
    let () = Test.set_source owner2_addr in
    let () = Token_helper.transfer_success(transfer_requests, tok.contr) in
    let () = Token_helper.assert_balance(tok.taddr, owner1_addr, 1n, 8n) in
    let () = Token_helper.assert_balance(tok.taddr, owner2_addr, 1n, 2n) in
    Token_helper.assert_no_permit(tok.taddr, (owner1_addr, hash_))

(* Failing because the permit has expired *)
let test_failure_expired_permit =
    let init_default_expiry = 86_400n in
    let init_max_expiry = 259_200n in
    let now = ("2000-01-03t10:10:10Z" : timestamp) in
    let expired = ("2000-01-01t10:10:10Z" : timestamp) in

    let (admin, owners, owners_with_keys, ops) = Bootstrap.boot_state(now) in
    let (owner1, owner2, _) = owners_with_keys in
    let (owner1_addr, _, _) = owner1 in
    let (owner2_addr, _, _) = owner2 in

    let transfer_request = ({
        from_=owner1_addr;
        tx=([{to_=owner2_addr;amount=2n;token_id=1n}] : Token.FA2.atomic_trans list)
    }) in
    let hash_ = Crypto.blake2b (Bytes.pack transfer_request) in

    let extended_storage = Token_helper.get_initial_extended_storage(admin, init_default_expiry, init_max_expiry) in
    let extended_storage = { extended_storage with
        permits = Big_map.literal [((owner1_addr, hash_), expired)];
        counter = 1n;
    } in

    let tok = Bootstrap.boot_token(owners, ops, init_tok_amount, extended_storage) in
    let () = Test.set_source owner2_addr in
    let r = Token_helper.transfer([transfer_request], tok.contr) in
    Assert.string_failure r Token.FA2.Errors.not_operator
