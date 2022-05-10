#import "./constants.mligo" "Constants"
#import "./errors.mligo" "Errors"
#import "./lambda.mligo" "Lambda"
#import "./outcome.mligo" "Outcome"
#import "./proposal.mligo" "Proposal"
#import "./storage.mligo" "Storage"
#import "./vote.mligo" "Vote"
#import "./token.mligo" "Token"
#import "./vault.mligo" "Vault"
#import "./timelock.mligo" "Timelock"

type parameter =
    Propose of Proposal.make_params
    | Cancel of nat option
    | Lock of Vault.amount_
    | Release of Vault.amount_
    | Execute of Outcome.execute_params
    | Vote of Vote.choice
    | End_vote

type storage = Storage.t
type result = operation list * storage

(**
    [execute(outcome_key, packed, s)] executes [packed] lambda and returns an operation list
    and the updated storage [s]. A lambda can either create an operation list or update the config.
    Raises: [Errors.outcome_not_found] if [outcome_key] does not occur in [Storage.outcomes].
    Raises: [Errors.canceled|Errors.already_executed|Errors.not_executable] if
    the outcome state is not equal to [Accepted].
    Raises: [Errors.timelock_not_found|Errors.timelock_locked] if a timelock
    does not exists or is locked.
    Raises [Errors.lambda_not_found|Errors.lambda_wrong_packed_data] if the lambda does not exists,
    or is not matching the stored hash.
    Raises [Errors.wrong_lambda_kind] if the unpacking of the lambda fails.
*)
let execute (outcome_key, packed, s: nat * bytes * storage) : result =
    let proposal = (match Big_map.find_opt outcome_key s.outcomes with
        None -> failwith Errors.outcome_not_found
        | Some(o) -> Outcome.get_proposal(o)) in

    let () = Timelock._check_unlocked(proposal.timelock) in
    let lambda_ = Lambda.validate(proposal.lambda, packed) in

    match lambda_.1 with
        OperationList -> (match (Bytes.unpack packed : Lambda.operation_list option) with
            Some(f) -> f(), Storage.update_outcome(outcome_key, (proposal, Executed), s)
            | None -> failwith Errors.wrong_lambda_kind)
        | ParameterChange -> (match (Bytes.unpack packed : Lambda.parameter_change option) with
            Some(f) ->
                Constants.no_operation,
                Storage.update_outcome(
                    outcome_key,
                    (proposal, Executed),
                    Storage.update_config(f,s)
                )
            | None -> failwith Errors.wrong_lambda_kind)

(**
    [propose(p, s)] creates a proposal from create parameters [p], then transfers configured
    deposit_amount of tokens to the DAO contract and updates storage [s] with the new proposal.
    Raises [Errors.proposal_already_exists] if there is already a proposal as only one
    proposal can exists at a time.
    Raises [Errors.receiver_not_found] if the governance token contract entrypoint is not found.
*)
let propose (p, s : Proposal.make_params * storage) : result =
    match s.proposal with
        Some(_) -> failwith Errors.proposal_already_exists
        | None -> [Token.transfer(
            s.governance_token,
            Tezos.sender,
            Tezos.self_address,
            s.config.deposit_amount
        )], Storage.create_proposal(
            Proposal.make(p, s.config.start_delay, s.config.voting_period),
            s)

(**
    [cancel (outcome_key_opt, s)] creates an operation of transfer of the deposited amount to the
    configured burn_address, and updates storage [s] with either an outcome creation of current
    proposal with its state canceled, or an update of the matched outcome at [outcome_key_opt]
    with its state Canceled.
    Raises [Errors.nothing_to_cancel] if [outcome_key_opt] is None and there is no current proposal.
    Raises [Errors.voting_period] if there is a current proposal and the current block minimal
    injection time belongs to the proposal voting period.
    Raises [Errors.not_creator] is the sender is not the proposal creator.
    Raises [Errors.outcome_not_found] if [outcome_key_opt] is not None, but it does not exists.
    Raises [Errors.already_executed] if the proposal have already been executed.
    Raises [Errors.timelock_not_found] if the outcome timelock does not exists.
    Raises [Errors.timelock_unlocked] if the outcome timelock is unlocked, a proposal outcome cannot be
    canceled if it is unlocked.
*)
let cancel (outcome_key_opt, s : nat option * storage) : result =
   [Token.transfer(
        s.governance_token,
        Tezos.self_address,
        s.config.burn_address,
        s.config.deposit_amount)
   ], (match outcome_key_opt with
        None -> (match s.proposal with
            None -> failwith Errors.nothing_to_cancel
            | Some(p) -> let () = Proposal._check_not_voting_period(p) in
                let _check_sender_is_creator = assert_with_error
                    (p.creator = Tezos.sender)
                    Errors.not_creator in
                Storage.add_outcome((p, Canceled), s))
        | Some(outcome_key) -> (match Big_map.find_opt outcome_key s.outcomes with
            None -> failwith Errors.outcome_not_found
            | Some(o) -> let (p, state) = o in
            let _check_sender_is_creator = assert_with_error
                (p.creator = Tezos.sender)
                Errors.not_creator in
            let _check_not_executed = assert_with_error
                (state <> Executed)
                Errors.already_executed in
            let () = Timelock._check_locked(p.timelock) in
            Storage.update_outcome(outcome_key, (p, Canceled), s)))

(**
    [lock(amount_)] creates an operation for token transfer between the owner and the DAO contract with [amount_],
    and updates storage [s] with the vault new balance to keep tracks of the transfer.
    Raises [Errors.voting_period] if a proposal exists and a vote is ongoing.
    Raises [FA2.Errors.ins_balance] if the owner has insufiscient balance.
    Requires the DAO address to have been added as operator on the governance token.
*)
let lock (amount_, s : nat * storage) : result =
    let () = Proposal._check_no_vote_ongoing(s.proposal) in
    let current_amount = Vault.get_for_user(s.vault, Tezos.sender) in

    [Token.transfer(s.governance_token, Tezos.sender, Tezos.self_address, amount_)],
    Storage.update_vault(Vault.update_for_user(
        s.vault,
        Tezos.sender,
        current_amount + amount_), s)

(**
    [release(amount_, s)] creates an operation for token transfer between the DAO and the owner with [amount_],
    and updates storage [s] with the vault new balance to keep tracks of the transfer.
    Raises [Errors.voting_period] if a vote is ongoing.
    Raises [Errors.no_locked_tokens] if the sender has no locked tokens.
    Raises [Errors.not_enough_balance] if [amount_] is superior to actual balance.
    Raises [FA2.Errors.ins_balance] if the DAO has insufiscient balance.
*)
let release (amount_, s : nat * storage) : result =
    let () = Proposal._check_no_vote_ongoing(s.proposal) in
    let current_amount = Vault.get_for_user_exn(s.vault, Tezos.sender) in
    let _check_balance = assert_with_error
        (current_amount >= amount_)
        Errors.not_enough_balance in

    [Token.transfer(s.governance_token, Tezos.self_address, Tezos.sender, amount_)],
    Storage.update_vault(Vault.update_for_user(
        s.vault,
        Tezos.sender,
        abs(current_amount - amount_)), s)

(**
    [vote(choice, s)] updates current proposal with the sender [choice] along with its voting power, and
    returns the updated storage [s]
    Raises [Errors.no_proposal] if there is no current proposal.
    Raises [Errors.not_voting_period] if the vote is not open.
    Raises [Errors.no_locked_tokens] if the sender has no locked tokens.
*)
let vote (choice, s : bool * storage) : storage =
    match s.proposal with
        None -> failwith Errors.no_proposal
        | Some(p) -> let () = Proposal._check_is_voting_period(p) in
            let amount_ = Vault.get_for_user_exn(s.vault, Tezos.sender) in
            Storage.update_votes(p, (choice, amount_), s)

(**
    [end_vote(s)] creates an operation of transfer from the DAO to either the proposal creator, or the
    configured burn_address, and updates storage [s] with new outcome.
    Raises [Errors.no_proposal] if there is no current proposal
    Raises [Errors.fa2_total_supply_not_found] if the configured governance_token total supply
    could not be found.
*)
let end_vote (s : storage) : result =
    match s.proposal with
        None -> failwith Errors.no_proposal
        | Some(p) -> let () = Proposal._check_voting_period_ended(p) in
            let total_supply = (match Token.get_total_supply(s.governance_token) with
                None -> failwith Errors.fa2_total_supply_not_found
                | Some n -> n) in
            let outcome = Outcome.make(
                    p,
                    total_supply,
                    s.config.refund_threshold,
                    s.config.quorum_threshold,
                    s.config.super_majority
                ) in
            let (_, state) = outcome in
            let transfer_to_addr = match state with
                Rejected_(WithoutRefund) -> s.config.burn_address
                | _ -> Tezos.sender
            in
            ([Token.transfer(
                s.governance_token,
                Tezos.self_address,
                transfer_to_addr,
                s.config.deposit_amount)]
            ), Storage.add_outcome(outcome, s)

(**
    Raises [Errors.not_zero_amount] if tez amount is sent.
*)
let main (action, store : parameter * storage) : result =
    let _check_amount_is_zero = assert_with_error
        (Tezos.amount = 0tez)
        Errors.not_zero_amount
    in match action with
        Propose p -> propose(p, store)
        | Cancel n_opt -> cancel(n_opt, store)
        | Lock n -> lock(n, store)
        | Release n -> release(n, store)
        | Execute p -> execute(p.outcome_key, p.packed, store)
        | Vote v -> Constants.no_operation, vote(v, store)
        | End_vote -> end_vote(store)
