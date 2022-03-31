#import "./proposal.mligo" "Proposal"
#import "./vote.mligo" "Vote"
#import "./errors.mligo" "Errors"

type rejected_state_extra = WithRefund | WithoutRefund
type state = Accepted | Rejected_ of rejected_state_extra | Executed | Canceled

type t = (Proposal.t * state)

type execute_params = 
    [@layout:comb]
    {
        outcome_key: nat;
        packed: bytes;
        // ^ the packed lambda
    }

(**
    [make(p, total_supply, refund_threshold, quorum_threshold, super_majority)] creates
    an outcome from [p] proposal, computing a state.
*)
let make (
    p, 
    total_supply, 
    refund_threshold, 
    quorum_threshold, 
    super_majority : Proposal.t * nat * nat * nat * nat
) : t = 
    let (total_votes, ok_votes, ko_votes) = Vote.count(p.votes) in
    let state = (if ((total_votes / total_supply * 100n) < refund_threshold)
        then Rejected_(WithoutRefund)
        else if ((ok_votes / total_votes * 100n) < super_majority) 
            || ((total_votes / total_supply * 100n) < quorum_threshold)
        then Rejected_(WithRefund)
        else if ok_votes > ko_votes then Accepted else Rejected_(WithRefund)) in
    (p, state)

(**
    [get_proposal(outcome)] gets the [outcome] proposal.
    Raises [Errors.canceled] if [outcome] state is [Canceled].
    Raises [Errors.already_executed] if [outcome] state is [Executed].
    Raises [Errors.not_executable] if [outcome] state is [Rejected_].
*)
let get_proposal(outcome : t) : Proposal.t =
    match outcome with 
        (_, Canceled) -> (failwith Errors.canceled : Proposal.t)
        | (_, Executed) -> (failwith Errors.already_executed : Proposal.t)
        | (_, Rejected_(_)) -> (failwith Errors.not_executable : Proposal.t)
        | (proposal, Accepted) -> proposal
