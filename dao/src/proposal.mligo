#import "./errors.mligo" "Errors"
#import "./lambda.mligo" "Lambda"
#import "./vote.mligo" "Vote"
#import "./timelock.mligo" "Timelock"

type t =
    [@layout:comb]
    {
        description_link: string;
        lambda: Lambda.t option;
        start_at: timestamp;
        end_at: timestamp;
        votes: Vote.votes;
        creator: address;
        timelock: Timelock.t option;
    }

type make_params =
    [@layout:comb]
    {
        description_link: string;
        lambda: Lambda.t option;
    }

let make (p, start_delay, voting_period : make_params * nat * nat) : t =
    let start_at = Tezos.now + int(start_delay) in
    {
        description_link = p.description_link;
        lambda = p.lambda;
        start_at = start_at;
        end_at = start_at + int(voting_period);
        votes = (Map.empty: Vote.votes);
        creator = Tezos.source;
        timelock = (None : Timelock.t option);
    }

(**
    [is_voting_period(p)] returns true if proposal [p] voting period is active, false otherwise.
    A proposal voting period starts at start_at timestamp and ends at end_at timestamp. 
    These timestamps are compared against the current block minimal injection time.
    See https://tezos.gitlab.io/michelson-reference/#instr-NOW
*)
let is_voting_period (p : t) = ((Tezos.now >= p.start_at) && (Tezos.now < p.end_at))

(**
    [_check_not_voting_period(p) checks that current block doesn't belong to proposal [p] voting period.
    Raises [Errors.voting_period] if the current block minimal injection time belongs to the proposal
    voting period.
*)
let _check_not_voting_period (p : t) : unit = 
    assert_with_error
        (not is_voting_period(p))
        Errors.voting_period

(**
    [_check_is_voting_period(p) checks that current block belongs to proposal [p] voting period.
    Raises [Errors.not_voting_period] if the current block minimal injection time does not belong 
    to the proposal voting period.
*)
let _check_is_voting_period (p : t ) : unit =
    assert_with_error
        (is_voting_period(p))
        Errors.not_voting_period

(**
    [_check_no_vote_ongoing(p_opt)] checks that proposal [p_opt] exists and the voting period is ongoing.
    Raises [Errors.voting_period] if a proposal exists and a vote is ongoing.
*)
let _check_no_vote_ongoing (p_opt : t option) = 
    match p_opt with
        Some(p) -> _check_not_voting_period(p)
        | None -> ()

(**
    [_check_voting_period_ended(p)] checks that proposal [p] voting period has ended.
    Raises [Errors.voting_period] if the current block minimal injection time is occuring after
    the proposal end_at timestamp.
*)
let _check_voting_period_ended (p : t) =
    assert_with_error 
        (Tezos.now > p.end_at) 
        Errors.voting_period
