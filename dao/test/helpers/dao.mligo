#import "../../src/main.mligo" "DAO"
#import "./time.mligo" "Time_helper"
#import "./assert.mligo" "Assert"

(* Some types for readability *)
type taddr = (DAO.parameter, DAO.storage) typed_address
type contr = DAO.parameter contract
type originated = {
    addr: address;
    taddr: taddr;
    contr: contr;
}

(* Pack and hash of a lambda returning an empty operation list *)
let empty_op_list_packed = Bytes.pack (fun() -> ([] :operation list))
let empty_op_list_hash = Crypto.sha256 empty_op_list_packed

(* Some dummy values intended to be used as placeholders *)
let dummy_packed = 0x05030b
let dummy_hash = 0x01
let dummy_proposal = {
    description_link = "ipfs://QmbKq7QriWWU74NSq35sDSgUf24bYWTgpBq3Lea7A3d7jU";
    lambda = Some((0x01, ParameterChange))
}

(* Some default values *)
let default_votes = (Map.empty : DAO.Vote.votes)
let default_timelock = (None : DAO.Timelock.t option)

let base_config : DAO.Storage.Config.t = {
    deposit_amount = 4n;
    refund_threshold = 32n;
    quorum_threshold = 67n;
    super_majority = 80n;
    start_delay = Time_helper.cycletime;
    voting_period = Time_helper.cycletime * 4n;
    timelock_delay = Time_helper.cycletime;
    timelock_period = Time_helper.cycletime * 2n;
    burn_address = ("tz1burnburnburnburnburnburnburjAYjjX": address);
}

let base_storage (governance_token : DAO.Storage.Token.t) : DAO.storage = {
    metadata = Big_map.literal [
        ("", Bytes.pack("tezos-storage:contents"));
        ("contents", ("": bytes))
    ];
    governance_token = governance_token;
    vault = (Big_map.empty : DAO.Storage.Vault.t);
    proposal = (None : DAO.Proposal.t option);
    config = base_config;
    next_outcome_id = 1n;
    outcomes = (Big_map.empty : DAO.Storage.outcomes);
}

(* Originate a DAO contract with given init_storage storage *)
let originate (init_storage: DAO.storage) =
    let (taddr, _, _) = Test.originate DAO.main init_storage 0tez in
    let contr = Test.to_contract taddr in
    let addr = Tezos.address contr in
    { addr = addr; taddr = taddr; contr = contr }

(* Call entry point of DAO contr contract *)
let call (p, contr : DAO.parameter * contr) =
    Test.transfer_to_contract contr p 0mutez

(* Entry points call helpers *)
let cancel (outcome_key_opt, contr : nat option * contr) = call(Cancel(outcome_key_opt), contr)

let end_vote (contr : contr) = call(End_vote, contr)

let execute (k, packed, contr : nat * bytes * contr) =
    call(Execute({ outcome_key = k; packed = packed; }), contr)

let lock (amount_, contr: nat * contr) = call(Lock(amount_), contr)

let propose (proposal, contr : DAO.Proposal.make_params * contr) =
    call(Propose(proposal), contr)

let release (amount_, contr: nat * contr) = call(Release(amount_), contr)

let vote (choice, contr: bool * contr) = call(Vote(choice), contr)

(* Asserter helper for successful entry point calls *)
let cancel_success (outcome_key_opt, contr : nat option * contr) =
    Assert.tx_success (cancel(outcome_key_opt, contr))

let end_vote_success (contr : contr) =
    Assert.tx_success (end_vote(contr))

let execute_success (k, packed, contr : nat * bytes * contr) =
    Assert.tx_success (execute(k, packed, contr))

let lock_success (amount_, contr: nat * contr) =
    Assert.tx_success (lock(amount_, contr))

let propose_success (proposal, contr : DAO.Proposal.make_params * contr) =
    Assert.tx_success (propose(proposal, contr))

let release_success (amount_, contr: nat * contr) =
    Assert.tx_success (release(amount_, contr))

let vote_success (choice, contr: DAO.Vote.choice * contr) =
    Assert.tx_success (vote(choice, contr))


(* Batch call of lock entry point, WARNING: changes Test framework source *)
let batch_lock (addr_lst, amount_, contr : address list * nat * contr) =
    let lock = fun (addr : address) ->
        let () = Test.set_source addr in lock_success(amount_, contr)
    in List.iter lock addr_lst

(* Batch call of vote entry point, WARNING: changes Test framework source *)
let batch_vote (addr_lst, choice, contr : address list * DAO.Vote.choice * contr) =
    let vote = fun (addr : address) ->
        let () = Test.set_source addr in vote_success(choice, contr)
    in List.iter vote addr_lst

(* Assert DAO contract at [taddr] has [owner] [amount_] of tokens locked *)
let assert_locked (taddr, owner, amount_ : taddr * DAO.Storage.Vault.owner *  nat) =
    let s = Test.get_storage taddr in
    match Big_map.find_opt owner s.vault with
        Some tokens -> assert(tokens = amount_)
        | None -> failwith("Big_map key should not be missing")

(* Assert DAO contract at [taddr] have registered [voter] [choice] with [amount_] votes *)
let assert_voted (taddr, voter, choice, amount_ : taddr * address * bool * nat) =
    let s = Test.get_storage taddr in
    let p = Option.unopt(s.proposal) in
    match Map.find_opt voter p.votes with
        Some vote -> assert(vote.0 = choice && vote.1 = amount_)
        | None -> failwith("Map key should not be missing")

(* Assert DAO contract at [taddr] have an outcome occuring for [n] key in Executed state *)
let assert_executed (taddr, n : taddr * nat) =
    let s = Test.get_storage taddr in
    match Big_map.find_opt 1n s.outcomes with
        None -> failwith "The outcome should exists"
        | Some(p, state) -> assert(state = Executed)

(* Assert outcomes [bm] big map have an entry for key [k] and has given [s] state *)
let assert_proposal_state (bm, k, s : DAO.Storage.outcomes * nat * DAO.Outcome.state) =
    match Big_map.find_opt k bm with
        Some(outcome) -> let (proposal, state) = outcome in
            (* just checking timelock existence *)
            let _check_timelock = proposal.timelock in
            (* check that the proposal have been accepted *)
            assert(state = s)
        | None -> failwith("outcome not found")

