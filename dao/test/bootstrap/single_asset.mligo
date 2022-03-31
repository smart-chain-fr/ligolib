#include "tezos-ligo-fa2/lib/fa2/asset/single_asset.mligo"

(* Extension of FA2 to be used as governance token of the DAO *)

[@view] let total_supply  (_, s : unit * storage) : nat =
    30n
