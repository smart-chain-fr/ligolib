#include "../advisor.mligo"
#include "../indice.mligo"

let test =
  
  // deploy INDICE contract 
  let indice_initial_storage = 4 in
  let iis = Test.run (fun (x:indiceStorage) -> x) indice_initial_storage in
  let indice_contract_path = "views_hangzhou/cameligo/indice.mligo" in
  let (address_indice, code_indice, _) = Test.originate_from_file indice_contract_path "indiceMain" (["indice_value"] : string list) iis 0tez in
  let actual_storage = Test.get_storage_of_address address_indice in
  let indice_taddress = (Test.cast_address address_indice : (indiceEntrypoints,indiceStorage) typed_address) in
  let indice_contract = Test.to_contract indice_taddress in

  // INDICE Increment(1)
  let () = Test.transfer_to_contract_exn indice_contract (Increment(1)) 0mutez in
  let inc_actual_storage = Test.get_storage indice_taddress in
  let () = Test.log(inc_actual_storage) in
  let () = assert(inc_actual_storage = indice_initial_storage + 1) in

  //deploy ADVISOR contract 
  let advisor_initial_storage : advisorStorage = {indiceAddress=address_indice; algorithm=(fun(i : int) -> if i < 10 then True else False); result=False} in
  let ais = Test.run (fun (x:advisorStorage) -> x) advisor_initial_storage in
  let advisor_contract_path = "views_hangzhou/cameligo/advisor.mligo" in
  let (address_advisor, code_advisor, _) = Test.originate_from_file advisor_contract_path "advisorMain" ([] : string list) ais 0tez in
  let advisor_taddress = (Test.cast_address address_advisor : (advisorEntrypoints,advisorStorage) typed_address) in
  let advisor_contract = Test.to_contract advisor_taddress in

  // ADVISOR call ExecuteAlgorithm
  let () = Test.transfer_to_contract_exn advisor_contract (ExecuteAlgorithm(unit)) 0mutez in
  let advisor_modified_storage = Test.get_storage advisor_taddress in
  let () = Test.log(advisor_modified_storage) in
  assert(advisor_modified_storage.result = True)
