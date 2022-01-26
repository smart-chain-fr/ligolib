#import "../../src/common/featurev2.mligo" "FeatureV2"

let empty : FeatureV2.storage = Big_map.empty

let test_increment =
    let (taddr, _, _) = Test.originate FeatureV2.main empty 0tez in
    let contr = Test.to_contract taddr in
    let sender_ = Test.nth_bootstrap_account 0 in
    let () = Test.set_source sender_ in
    let _ = Test.transfer_to_contract_exn contr (Increment(1)) 0mutez in
    let new_storage = Test.get_storage taddr in
    assert (new_storage = Big_map.literal [sender_, 1])

let test_decrement =
    let (taddr, _, _) = Test.originate FeatureV2.main empty 0tez in
    let contr = Test.to_contract taddr in
    let sender_ = Test.nth_bootstrap_account 0 in
    let () = Test.set_source sender_ in
    let _ = Test.transfer_to_contract_exn contr (Decrement(1)) 0mutez in
    let new_storage = Test.get_storage taddr in
    assert (new_storage = Big_map.literal [sender_, -1])

let test_reset =
    let sender_ = Test.nth_bootstrap_account 0 in
    let (taddr, _, _) = Test.originate FeatureV2.main (Big_map.literal [sender_, 21]) 0tez in
    let contr = Test.to_contract taddr in
    let () = Test.set_source sender_ in
    let _ = Test.transfer_to_contract_exn contr Reset 0mutez in
    let new_storage = Test.get_storage taddr in
    assert (new_storage = Big_map.literal [sender_, 0])
