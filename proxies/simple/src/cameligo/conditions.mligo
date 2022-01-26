#import "errors.mligo" "Errors" 

[@inline][@no_mutation]
let only_sender(sender_:address) = 
  assert_with_error (Tezos.sender = sender_) Errors.sender_not_allowed

[@inline][@no_mutation]
let amount_must_be_zero_tez(): unit =
    assert_with_error (Tezos.amount = 0tez) Errors.not_zero_amount
