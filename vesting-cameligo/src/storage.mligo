type fa_type = FA1 of address | FA2 of address

type t = {
    token_address : fa_type;
    token_id : nat;
    beneficiaries : (address, nat) map;
    revocable : bool;
    release_duration : nat;
    cliff_duration : nat;
    admin : address;
    released : (address, nat) map;
    revoked : bool;
    revoked_addresses : (address, bool) map;
    vested_amount : nat;
    started : bool;
    total_released : nat;
    end_of_cliff : timestamp option;
    vesting_end : timestamp option;
    start : timestamp option;
    metadata : (string, bytes) big_map;
}
