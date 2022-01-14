#import "../../advisor.mligo" "ADVISOR"
#import "../../indice.mligo" "INDICE"

let test =
  
  // deploy INDICE A contract 
  let indice_initial_storage = 10 in
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
  //let () = Test.log(inc_actual_storage) in
  let () = assert(inc_actual_storage = indice_initial_storage + 1) in

// INDICE Decrement(1)
  let () = Test.transfer_to_contract_exn indice_contract (Decrement(1)) 0mutez in
  let dec_actual_storage = Test.get_storage indice_taddress in
  let () = Test.log(dec_actual_storage) in
  let () = assert(dec_actual_storage = inc_actual_storage - 1) in

  // deploy INDICE B contract 
  let indiceB_initial_storage = 6 in
  let iBis = Test.run (fun (x:INDICE.indiceStorage) -> x) indiceB_initial_storage in
  // path relative to where the command run test in runned
  let indiceB_contract_path = "indice.mligo" in //"views_hangzhou/cameligo/indice.mligo" in
  let (address_indiceB, code_indiceB, _) = Test.originate_from_file indiceB_contract_path "indiceMain" (["indice_value"] : string list) iBis 0tez in
  let actual_storageB = Test.get_storage_of_address address_indiceB in
    let () = Test.log(actual_storageB) in
  let indiceB_taddress = (Test.cast_address address_indiceB : (INDICE.indiceEntrypoints,INDICE.indiceStorage) typed_address) in
  let indiceB_contract = Test.to_contract indiceB_taddress in


  // deploy ADVISOR contract 
  let advisor_initial_storage : ADVISOR.advisorStorage = {indices=[{contractAddress=address_indice; viewName="indice_value"}; {contractAddress=address_indiceB; viewName="indice_value"}]; algorithm=(fun(l : int list) -> let i : int = match List.head_opt l with | None -> (failwith("missing value") : int) | Some(v) -> v in if i < 10 then True else False); result=False} in
  let ais = Test.run (fun (x:ADVISOR.advisorStorage) -> x) advisor_initial_storage in
  //let () = Test.log(ais) in
  let advisor_contract_path = "advisor.mligo" in //"views_hangzhou/cameligo/advisor.mligo" in
  let (address_advisor, code_advisor, _) = Test.originate_from_file advisor_contract_path "advisorMain" ([] : string list) ais 0tez in
  let advisor_taddress = (Test.cast_address address_advisor : (ADVISOR.advisorEntrypoints,ADVISOR.advisorStorage) typed_address) in
  let advisor_contract = Test.to_contract advisor_taddress in

  let () = Test.log("check if head of list < 10") in

  // ADVISOR call ExecuteAlgorithm
  let () = Test.transfer_to_contract_exn advisor_contract (ExecuteAlgorithm(unit)) 0mutez in
  let advisor_modified_storage = Test.get_storage advisor_taddress in
  let () = Test.log(advisor_modified_storage) in
  let () = assert(advisor_modified_storage.result = False) in

  // ADVISOR call ChangeAlgorithm
  // check if head of list < 20
  let new_algo : (int list) -> bool = (fun(l : int list) -> let i : int = match List.head_opt l with | None -> (failwith("missing value") : int) | Some(v) -> v in if i < 20 then True else False) in
  let () = Test.log("check if head of list < 20") in
  let () = Test.transfer_to_contract_exn advisor_contract (ChangeAlgorithm(new_algo)) 0mutez in
  let advisor_modified_storage2 = Test.get_storage advisor_taddress in

  // ADVISOR call ExecuteAlgorithm
  let () = Test.transfer_to_contract_exn advisor_contract (ExecuteAlgorithm(unit)) 0mutez in
  let advisor_modified_storage3 = Test.get_storage advisor_taddress in
  let () = Test.log(advisor_modified_storage3) in
  let () = assert(advisor_modified_storage3.result = True) in

  
  // check if mean of the list < 7
  let algo_mean : (int list) -> bool = (fun(l : int list) -> let _check : bool = match List.head_opt l with | None -> (failwith("empty list") : bool) | Some (_v) -> True in let (sum, size) : int * nat = List.fold (fun((acc, nb), elt : (int * nat) * int) : (int * nat) -> (acc + elt, nb + 1n)) l (0, 0n) in let mean : int = sum / size in if mean < 7 then True else False) in
  let () = Test.log("check if mean of the list < 7") in
  let () = Test.transfer_to_contract_exn advisor_contract (ChangeAlgorithm(algo_mean)) 0mutez in
  let advisor_modified_storage3 = Test.get_storage advisor_taddress in
  //let ams2 = Test.run (fun (x:ADVISOR.advisorStorage) -> x) advisor_modified_storage2 in
  //let () = Test.log(ams2) in
  //let () = Test.log(advisor_modified_storage2.algorithm) in

  // ADVISOR call ExecuteAlgorithm
  let () = Test.transfer_to_contract_exn advisor_contract (ExecuteAlgorithm(unit)) 0mutez in
  let advisor_modified_storage4 = Test.get_storage advisor_taddress in
  let () = Test.log(advisor_modified_storage4) in
  assert(advisor_modified_storage4.result = False)
