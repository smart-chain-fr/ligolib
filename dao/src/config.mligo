(*
    quorum_threshold, refund_threshold and super_majority
    are represented with scale = 2, ex. 80 = .80 = 80%

    x_delay and x_period are represented by time units in seconds
*)
type t =
    [@layout:comb]
    {
        deposit_amount: nat;
        (* ^ The amount of tokens required to be deposited when creating a proposal *)

        refund_threshold: nat;
        (* ^ The minimal amount of participating tokens required for the deposit to be refunded *)

        quorum_threshold: nat;
        (* ^ The minimal participation percentage needed for a proposal to pass *)

        super_majority: nat;
        (* ^ The percentage needed for a super majority ("yes" votes) *)

        start_delay: nat;
        (* ^ The delay for the vote to start *)

        voting_period: nat;
        (* ^ The period during which voting is live *)

        timelock_delay: nat;
        (* ^ Delay before an approved proposal can be executed *)

        timelock_period: nat;
        (* ^ The period during which a timelock can be executed *)

        burn_address: address;
        (* ^ The burn address for unrefunded deposits *)
    }
