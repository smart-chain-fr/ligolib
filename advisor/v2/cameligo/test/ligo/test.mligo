#import "../../advisor.mligo" "ADVISOR"
#import "../../indice.mligo" "INDICE"

let test =
  
  // deploy INDICE A contract 
  let indice_initial_storage = 4 in
  let iis = Test.run (fun (x:INDICE.indiceStorage) -> x) indice_initial_storage in
  // path relative to where the command run test in runned
  let indice_contract_path = "indice.mligo" in //"views_hangzhou/cameligo/indice.mligo" in
  let (address_indice, code_indice, _) = Test.originate_from_file indice_contract_path "indiceMain" (["indice_value"] : string list) iis 0tez in
  let actual_storage = Test.get_storage_of_address address_indice in
  let indice_taddress = (Test.cast_address address_indice : (INDICE.indiceEntrypoints,INDICE.indiceStorage) typed_address) in
  let indice_contract = Test.to_contract indice_taddress in

  // INDICE Increment(1)
  let () = Test.transfer_to_contract_exn indice_contract (Increment(1)) 0mutez in
  let inc_actual_storage = Test.get_storage indice_taddress in
  let () = Test.log(inc_actual_storage) in
  let () = assert(inc_actual_storage = indice_initial_storage + 1) in

// INDICE Decrement(2)
  let () = Test.transfer_to_contract_exn indice_contract (Decrement(2)) 0mutez in
  let dec_actual_storage = Test.get_storage indice_taddress in
  let () = Test.log(dec_actual_storage) in
  let () = assert(dec_actual_storage = inc_actual_storage - 2) in

  // deploy INDICE B contract 
  let indiceB_initial_storage = 4 in
  let iBis = Test.run (fun (x:INDICE.indiceStorage) -> x) indiceB_initial_storage in
  // path relative to where the command run test in runned
  let indiceB_contract_path = "indice.mligo" in //"views_hangzhou/cameligo/indice.mligo" in
  let (address_indiceB, code_indiceB, _) = Test.originate_from_file indiceB_contract_path "indiceMain" (["indice_value"] : string list) iBis 0tez in
  let actual_storageB = Test.get_storage_of_address address_indiceB in
  let indiceB_taddress = (Test.cast_address address_indiceB : (INDICE.indiceEntrypoints,INDICE.indiceStorage) typed_address) in
  let indiceB_contract = Test.to_contract indiceB_taddress in


  // deploy ADVISOR contract 
  let advisor_initial_storage : ADVISOR.advisorStorage = {indices=[{contractAddress=address_indice; viewName="indice_value"}; {contractAddress=address_indiceB; viewName="indice_value"}]; algorithm=(fun(l : int list) -> let i : int = match List.head_opt l with | None -> (failwith("missing value") : int) | Some(v) -> v in if i < 10 then True else False); result=False} in
  let ais = Test.run (fun (x:ADVISOR.advisorStorage) -> x) advisor_initial_storage in
  let advisor_contract_path = "advisor.mligo" in //"views_hangzhou/cameligo/advisor.mligo" in
  let (address_advisor, code_advisor, _) = Test.originate_from_file advisor_contract_path "advisorMain" ([] : string list) ais 0tez in
  let advisor_taddress = (Test.cast_address address_advisor : (ADVISOR.advisorEntrypoints,ADVISOR.advisorStorage) typed_address) in
  let advisor_contract = Test.to_contract advisor_taddress in

  // ADVISOR call ExecuteAlgorithm
  let () = Test.transfer_to_contract_exn advisor_contract (ExecuteAlgorithm(unit)) 0mutez in
  let advisor_modified_storage = Test.get_storage advisor_taddress in
  let () = Test.log(advisor_modified_storage) in
  let () = assert(advisor_modified_storage.result = True) in

  // ADVISOR call ChangeAlgorithm
  let new_algo : (int list) -> bool = (fun(l : int list) -> let i : int = match List.head_opt l with | None -> (failwith("missing value") : int) | Some(v) -> v in if i < 3 then True else False) in
  let () = Test.transfer_to_contract_exn advisor_contract (ChangeAlgorithm(new_algo)) 0mutez in
  let advisor_modified_storage2 = Test.get_storage advisor_taddress in
  //let () = Test.log(advisor_modified_storage2.algorithm) in

  // ADVISOR call ExecuteAlgorithm
  let () = Test.transfer_to_contract_exn advisor_contract (ExecuteAlgorithm(unit)) 0mutez in
  let advisor_modified_storage3 = Test.get_storage advisor_taddress in
  let () = Test.log(advisor_modified_storage3) in
  assert(advisor_modified_storage3.result = False)
