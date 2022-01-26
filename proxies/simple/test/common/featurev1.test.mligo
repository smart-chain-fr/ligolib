#import "../../src/common/featurev1.mligo" "FeatureV1"

let test_increment =
    let (taddr, _, _) = Test.originate FeatureV1.main 0 0tez in
    let contr = Test.to_contract taddr in
    let sender_ = Test.nth_bootstrap_account 0 in
    let () = Test.set_source sender_ in
    let _ = Test.transfer_to_contract_exn contr (Increment(1)) 0mutez in
    let new_storage = Test.get_storage taddr in
    assert (new_storage = 1)

let test_decrement =
    let (taddr, _, _) = Test.originate FeatureV1.main 2 0tez in
    let contr = Test.to_contract taddr in
    let sender_ = Test.nth_bootstrap_account 0 in
    let () = Test.set_source sender_ in
    let _ = Test.transfer_to_contract_exn contr (Decrement(1)) 0mutez in
    let new_storage = Test.get_storage taddr in
    assert (new_storage = 1)

let test_reset =
    let (taddr, _, _) = Test.originate FeatureV1.main 2 0tez in
    let contr = Test.to_contract taddr in
    let sender_ = Test.nth_bootstrap_account 0 in
    let () = Test.set_source sender_ in
    let _ = Test.transfer_to_contract_exn contr Reset 0mutez in
    let new_storage = Test.get_storage taddr in
    assert (new_storage = 0)
