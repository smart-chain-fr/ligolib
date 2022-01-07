#include "../advisor.mligo"
#include "../indice.mligo"

let test =
  let indice_initial_storage = 4 in
  let (indice_taddr, _, _) = Test.originate indiceMain indice_initial_storage 0tez in  
  //let (indice_taddr, _, _) = Test.originate_from_file "../compiled/indice.tz" "indiceMain" ["indice_value"] indice_initial_storage 0tez in
  let current_storage = Test.get_storage indice_taddr in
  let () = Test.log(current_storage) in
  let indice_contract = Test.to_contract indice_taddr in
  let indice_address = Tezos.address indice_contract in 

  let () = Test.transfer_to_contract_exn indice_contract (Increment(1)) 0mutez in
  let modified_storage = Test.get_storage indice_taddr in
  let () = Test.log(modified_storage) in
  let () = assert(modified_storage = current_storage + 1) in
  let () = Test.log(indice_address) in

  let advisor_initial_storage : advisorStorage = {indiceAddress=indice_address; algorithm=(fun(i : int) -> if i < 10 then True else False); result=False} in
  let (advisor_taddr, _, _) = Test.originate advisorMain advisor_initial_storage 0tez in
  let advisor_current_storage = Test.get_storage advisor_taddr in
  let () = Test.log(advisor_current_storage) in
  let () = assert(advisor_current_storage.result = False) in
  let advisor_contract = Test.to_contract advisor_taddr in

  let () = Test.transfer_to_contract_exn advisor_contract (ExecuteAlgorithm(unit)) 0mutez in
  let advisor_modified_storage = Test.get_storage advisor_taddr in
  assert(advisor_modified_storage.result = True)

