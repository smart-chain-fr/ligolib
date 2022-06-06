#import "./config.mligo" "Config"
#import "./lambda.mligo" "Lambda"
#import "./metadata.mligo" "Metadata"
#import "./outcome.mligo" "Outcome"
#import "./proposal.mligo" "Proposal"
#import "./timelock.mligo" "Timelock"
#import "./token.mligo" "Token"
#import "./vault.mligo" "Vault"
#import "./vote.mligo" "Vote"

type outcomes = (nat, Outcome.t) big_map

type t =
    [@layout:comb]
    {
        metadata: Metadata.t;
        governance_token: Token.t;
        config: Config.t;
        vault: Vault.t;
        proposal: Proposal.t option;
        outcomes: outcomes;
        next_outcome_id: nat;
    }

let create_proposal (p, s : Proposal.t * t) : t =
    { s with proposal = Some(p) }

let update_config (f, s : Lambda.parameter_change * t) : t =
    { s with config = f() }

let update_vault (v, s : Vault.t * t) : t =
    { s with vault = v }

let update_votes (p, v, s : Proposal.t * Vote.t * t) : t =
    let new_votes = Map.update Tezos.sender (Some(v)) p.votes in
    let new_proposal = { p with votes = new_votes } in
    { s with proposal = Some(new_proposal) }

let update_outcome (k, o, s : nat * Outcome.t * t) : t =
    { s with outcomes = Big_map.update k (Some(o)) s.outcomes}

let add_outcome (o, s : Outcome.t * t) : t =
    let (proposal, status) = o in
    let proposal = (match status with
        (* If proposal is accepted, also create timelock *)
        Accepted -> let unlock_at = Tezos.now + int(s.config.timelock_delay) in
            { proposal with timelock = Some(Timelock.make(
                unlock_at,
                s.config.timelock_period)
            )}
        | _ -> proposal)
    in
    { s with
        proposal = (None : Proposal.t option);
        outcomes = Big_map.update s.next_outcome_id (Some(proposal, status)) s.outcomes;
        next_outcome_id = s.next_outcome_id + 1n
    }
