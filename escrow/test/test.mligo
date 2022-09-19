let test =
  let folded = fun (i,j : nat * (string * address)) -> i + 1n in
  let initial_storage = {
    admin = ("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address);
    currencies = Map.literal[("TZBTC", ("KT1MdenM9nqSvRnoLinXwU6dKYkug6upkezM" : address))];
    escrows = Map.literal[("escrow1", {currency = "TZBTC"; amount = 100n; buyer = ("tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur" : address); seller = ("tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF" : address); escrowContract = (None : address option); canceled = false; released = false; paid = true })];
    judges = (Map.empty : (nat, address) map);
    votingContract = ("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)} in
  let (taddr, _, _) = Test.originate main initial_storage 0tez in
  let current_storage : paymentStorage = Test.get_storage taddr in
  let nb_currencies : nat = Map.fold folded current_storage.currencies 0n in
  let () = assert(nb_currencies = 1n) in
  let () = Test.log("nbcur") in 
  let () = Test.log(nb_currencies) in
  let () = Test.log(current_storage) in
  let contr = Test.to_contract taddr in
  let () = Test.set_source ("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address) in
  let () = Test.transfer_to_contract_exn contr (AddCurrency("ETHTZ", ("KT1RmgE6SFgHFbKZDQsCCBz8jLvFyDd3z1su" : address))) 0mutez in
  let modified_storage = Test.get_storage taddr in
  let nb_currencies_after_add : nat = Map.fold folded modified_storage.currencies 0n in
  assert(nb_currencies_after_add = 2n)