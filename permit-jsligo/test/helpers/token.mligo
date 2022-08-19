#import "../../src/main.jsligo" "Token"
#import "./assert.mligo" "Assert"

(* Some types for readability *)
type taddr = (Token.parameter, Token.storage) typed_address
type contr = Token.parameter contract
type originated = {
    addr: address;
    taddr: taddr;
    owners: address list;
    contr: contr;
}

(* Some dummy values when they don't matter for a given test *)
let dummy_default_expiry = 0n
let dummy_max_expiry = 0n

let get_initial_extended_storage (admin, default_expiry, max_expiry: address * nat * nat) =
{
    admin = admin;
    counter = 0n;
    default_expiry = default_expiry;
    max_expiry = max_expiry;
    permits = (Big_map.empty : Token.Extension.permits);
    user_expiries = (Big_map.empty : Token.Extension.user_expiries);
    permit_expiries = (Big_map.empty : Token.Extension.permit_expiries);
    token_total_supply = (Big_map.empty : Token.Extension.token_total_supply)
}

(* Originate a Token contract with given init_storage storage *)
let originate (init_storage: Token.storage) =
    let (taddr, _, _) = Test.originate Token.main init_storage 0tez in
    let contr = Test.to_contract taddr in
    let addr = Tezos.address contr in
    { addr = addr; taddr = taddr; contr = contr }


let originate_from_file (init_storage : Token.storage) =
    let f = "./src/main.jsligo" in
    let v_mich = Test.run (fun (x: Token.storage) -> x) init_storage in
    let (addr, _, _) = Test.originate_from_file f "main" (["_get_default_expiry"; "_get_counter"] : string list) v_mich 0tez in
    let taddr : taddr = Test.cast_address addr in
    let contr = Test.to_contract taddr in
    {addr = addr; taddr = taddr; contr = contr}

(*
    Make a permit with given packed params and secret key
    The chain_id is equal to 0x00000000 in the test framework
*)
let make_permit (hash_, account, token_addr, counter : bytes * (address * key * string) * address * nat) : Token.permit_params =
    let (_, pub_key, secret_key) = account in
    let packed = Bytes.pack ((0x00000000, token_addr), (counter, hash_)) in
    let sig = Test.sign secret_key packed in
    (pub_key, (sig, hash_))

(* Call entry point of Token contr contract *)
let call (p, contr : Token.parameter * contr) =
    Test.transfer_to_contract contr p 0mutez

let permit (p, contr : Token.permit_params list * contr) =
    call(Permit(p), contr)

let set_expiry (p, contr : Token.expiry_params * contr) =
    call(SetExpiry(p), contr)

let set_admin (p, contr : address * contr) =
    call(SetAdmin(p), contr)

let transfer (p, contr : Token.FA2.transfer * contr) =
    let p : Token.parameter = Transfer(p) in
    call(p, contr)

let create_token (md, owner, amount, contr : Token.FA2.TokenMetadata.data * address * nat * contr) =
    call(Create_token(md, owner, amount), contr)

let mint_token (p, contr : Token.mint_or_burn list * contr) =
    call(Mint_token(p), contr)

let burn_token (p, contr : Token.mint_or_burn list * contr) =
    call(Burn_token(p), contr)

let permit_success (p, contr : Token.permit_params list * contr) =
    Assert.tx_success (permit(p, contr))

let set_expiry_success (p, contr : Token.expiry_params * contr) =
    Assert.tx_success (set_expiry(p, contr))

let set_admin_success (p, contr : address * contr) =
    Assert.tx_success (set_admin(p, contr))

let transfer_success (p, contr : Token.FA2.transfer * contr) =
    Assert.tx_success (transfer(p, contr))

let create_token_success (md, owner, amount, contr : Token.FA2.TokenMetadata.data * address * nat * contr) =
    Assert.tx_success (create_token(md, owner, amount, contr))

let mint_token_success (p, contr : Token.mint_or_burn list * contr) =
    Assert.tx_success (mint_token(p, contr))

let burn_token_success (p, contr : Token.mint_or_burn list * contr) =
    Assert.tx_success (burn_token(p, contr))

(* Assert Token contract at [taddr] has permit with [address, hash] key *)
let assert_has_permit (taddr, permit_key : taddr * Token.Extension.permit_key) =
    let s = Test.get_storage taddr in
    match Big_map.find_opt permit_key s.extension.permits with
        Some _ -> ()
        | None -> Test.failwith("Permits Big_map key should not be missing")

(* Assert Token contract at [taddr] has no permit with [address, hash] key *)
let assert_no_permit (taddr, permit_key : taddr * Token.Extension.permit_key) =
    let s = Test.get_storage taddr in
    match Big_map.find_opt permit_key s.extension.permits with
        Some _ -> Test.failwith("Permits Big_map key should be None")
        | None -> ()

(* Assert Token contract at [taddr] has counter equals to [counter] *)
let assert_counter (taddr, counter : taddr * nat) =
    let s = Test.get_storage taddr in
    assert_with_error
        (s.extension.counter = counter)
        "Counter does not have expected value"

(* Assert Token contract at [taddr] has user expiry for [user_addr] equal to [seconds] *)
let assert_user_expiry (taddr, user_addr, seconds : taddr * address * nat option) =
    let s = Test.get_storage taddr in
    match Big_map.find_opt user_addr s.extension.user_expiries with
        Some s -> assert (s = seconds)
        | None -> Test.failwith("User epiries Big_map key should not be missing")

(* Assert Token contract at [taddr] has user permit expiry for [user_addr] and
hash [hash_] equal to [seconds] *)
let assert_permit_expiry (taddr, user_addr, hash_, seconds : taddr * address * bytes * nat option) =
    let s = Test.get_storage taddr in
    match Big_map.find_opt (user_addr, hash_) s.extension.permit_expiries with
        Some s -> assert (s = seconds)
        | None -> Test.failwith("Permit epiries Big_map key should not be missing")

(* assert Token contract at [taddr] have [owner] address with [amount_] tokens in its ledger *)
let assert_balance (taddr, owner, token_id, amount_ : taddr * address * nat * nat) =
    let s = Test.get_storage taddr in
    match Big_map.find_opt (owner, token_id) s.ledger with
        Some tokens -> assert(tokens = amount_)
        | None -> Test.failwith("Big_map key should not be missing")

(* assert Token contract at [taddr] have token_total_supply for [token_id] matching [amount_] *)
let assert_supply (taddr, token_id, amount_ : taddr * Token.FA2.Ledger.token_id * nat) =
    let s = Test.get_storage taddr in
    match Big_map.find_opt token_id s.extension.token_total_supply with
        Some tokens -> assert(tokens = amount_)
        | None -> Test.failwith("Big_map key should not be missing")
