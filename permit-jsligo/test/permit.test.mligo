#import "./helpers/token.mligo" "Token_helper"
#import "./helpers/log.mligo" "Log"
#import "./helpers/assert.mligo" "Assert"
#import "./bootstrap/bootstrap.mligo" "Bootstrap"
#import "../src/main.jsligo" "Token"

let () = Log.describe("[Permit] test suite")

(* Boostrapping of the test environment, *)
let init_tok_amount = 10n
let bootstrap (init_ts, init_default_expiry, init_max_expiry : timestamp * nat * nat) =
    let (admin, owners, owners_with_keys, ops) = Bootstrap.boot_state(init_ts) in
    let base_extended_storage = Token_helper.get_initial_extended_storage(admin, init_default_expiry, init_max_expiry) in
    let tok = Bootstrap.boot_token(owners, ops, init_tok_amount, base_extended_storage) in
    (tok, admin, owners_with_keys)

(* Successful permit creation *)
let test_success_add_permit_one =
    let (tok, _, owners) = bootstrap(("2000-01-01t10:10:10Z" : timestamp), 3600n, 7200n) in
    let (owner1, owner2, _) = owners in
    let (owner1_addr, _, _) = owner1 in
    let (owner2_addr, _, _) = owner2 in
    let transfer_requests = ([
        ({from_=owner1_addr; tx=([{to_=owner2_addr;amount=2n;token_id=1n}] : Token.FA2.atomic_trans list)});
    ] : Token.FA2.transfer) in
    let hash_ = Crypto.blake2b (Bytes.pack transfer_requests) in
    let permit = Token_helper.make_permit(hash_, owner1, tok.addr, 0n) in
    let () = Token_helper.permit_success([permit], tok.contr) in
    let () = Token_helper.assert_has_permit(tok.taddr, (owner1_addr, hash_)) in
    Token_helper.assert_counter(tok.taddr, 1n)

(* Successful successive permit creation *)
let test_success_add_permit_list =
    let (tok, _, owners) = bootstrap(("2000-01-01t10:10:10Z" : timestamp), 3600n, 7200n) in
    let (owner1, owner2, _) = owners in
    let (owner1_addr, _, _) = owner1 in
    let (owner2_addr, _, _) = owner2 in
    let transfer_requests = ([
        ({from_=owner1_addr; tx=([{to_=owner2_addr;amount=2n;token_id=1n}] : Token.FA2.atomic_trans list)});
    ] : Token.FA2.transfer) in
    let hash_ = Crypto.blake2b (Bytes.pack transfer_requests) in
    let permit1 = Token_helper.make_permit(hash_, owner1, tok.addr, 0n) in
    let transfer_requests = ([
        ({from_=owner2_addr; tx=([{to_=owner1_addr;amount=2n;token_id=1n}] : Token.FA2.atomic_trans list)});
    ] : Token.FA2.transfer) in
    let hash_ = Crypto.blake2b (Bytes.pack transfer_requests) in
    let permit2 = Token_helper.make_permit(hash_, owner2, tok.addr, 1n) in
    let () = Token_helper.permit_success([permit1; permit2], tok.contr) in
    let () = Token_helper.assert_has_permit(tok.taddr, (owner2_addr, hash_)) in
    Token_helper.assert_counter(tok.taddr, 2n)

(* Successful permit update *)
let test_success_update_permit =
    let init_default_expiry = 86_400n in
    let init_max_expiry = 259_200n in
    let now = ("2000-01-03t10:10:10Z" : timestamp) in
    let expired = ("2000-01-01t10:10:10Z" : timestamp) in

    let (admin, owners, owners_with_keys, ops) = Bootstrap.boot_state(now) in
    let (owner1, owner2, _) = owners_with_keys in
    let (owner1_addr, _, _) = owner1 in
    let (owner2_addr, _, _) = owner2 in

    let transfer_requests = ([
        ({from_=owner1_addr; tx=([{to_=owner2_addr;amount=2n;token_id=1n}] : Token.FA2.atomic_trans list)});
    ] : Token.FA2.transfer) in
    let hash_ = Crypto.blake2b (Bytes.pack transfer_requests) in

    let extended_storage = Token_helper.get_initial_extended_storage(admin, init_default_expiry, init_max_expiry) in
    let extended_storage = { extended_storage with
        permits = Big_map.literal [((owner1_addr, hash_), expired)];
        counter = 1n;
    } in

    let tok = Bootstrap.boot_token(owners, ops, init_tok_amount, extended_storage) in
    let permit = Token_helper.make_permit(hash_, owner1, tok.addr, 1n) in
    let () = Token_helper.permit_success([permit], tok.contr) in
    Token_helper.assert_has_permit(tok.taddr, (owner1_addr, hash_))

(* Failing permit update because it alredy exists and has not expired *)
let test_success_update_permit =
    let (tok, _, owners) = bootstrap(("2000-01-01t10:10:10Z" : timestamp), 3600n, 7200n) in
    let (owner1, owner2, _) = owners in
    let (owner1_addr, _, _) = owner1 in
    let (owner2_addr, _, _) = owner2 in
    let transfer_requests = ([
        ({from_=owner1_addr; tx=([{to_=owner2_addr;amount=2n;token_id=1n}] : Token.FA2.atomic_trans list)});
    ] : Token.FA2.transfer) in
    let hash_ = Crypto.blake2b (Bytes.pack transfer_requests) in
    let permit = Token_helper.make_permit(hash_, owner1, tok.addr, 0n) in
    let () = Token_helper.permit_success([permit], tok.contr) in
    let permit = Token_helper.make_permit(hash_, owner1, tok.addr, 1n) in
    let r = Token_helper.permit([permit], tok.contr) in
    Assert.string_failure r Token.Errors.dup_permit
