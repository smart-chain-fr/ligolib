#import "errors.mligo" "Errors"

[@inline]
let only_signer (signers: address set): unit = 
    assert_with_error (Set.mem Tezos.sender signers) Errors.only_signer

[@inline]
let amount_must_be_zero_tez (an_amout:tez): unit =
    assert_with_error (an_amout = 0tez) Errors.amount_must_be_zero_tez

[@inline]
let not_yet_signer (approved_signers: address set) : unit = 
    assert_with_error (Set.mem Tezos.sender approved_signers) Errors.has_already_signed


