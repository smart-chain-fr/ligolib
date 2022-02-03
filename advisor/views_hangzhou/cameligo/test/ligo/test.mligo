#import "../../advisor.mligo" "ADVISOR"
#import "../../indice.mligo" "INDICE"

// ========== DEPLOY CONTRACT HELPER ============
let originate_from_file (type s p) (file_path: string) (mainName : string) (views: string list) (storage: michelson_program) : address * (p,s) typed_address * p contract =
    let (address_contract, code_contract, _) = Test.originate_from_file file_path mainName views storage 0tez in
    let taddress_contract = (Test.cast_address address_contract : (p, s) typed_address) in
    address_contract, taddress_contract, Test.to_contract taddress_contract

let _test =
  // deploy INDICE smart contract 
  let indice_initial_storage = 4 in
  let () = Test.log("deploy INDICE smart contract") in
  let iis = Test.run (fun (x:INDICE.indiceStorage) -> x) indice_initial_storage in
  // path relative to where the command run test in runned
  //let indice_contract_path = "indice.mligo" in //"views_hangzhou/cameligo/indice.mligo" in
  //let (address_indice, code_indice, _) = Test.originate_from_file indice_contract_path "indiceMain" (["indice_value"] : string list) iis 0tez in
  //let actual_storage = Test.get_storage_of_address address_indice in
  //let indice_taddress = (Test.cast_address address_indice : (INDICE.indiceEntrypoints,INDICE.indiceStorage) typed_address) in
  //let indice_contract = Test.to_contract indice_taddress in
  let (address_indice, indice_taddress, indice_contract) : address * (INDICE.indiceEntrypoints, INDICE.indiceStorage) typed_address * INDICE.indiceEntrypoints contract = 
    originate_from_file "indice.mligo" "indiceMain" (["indice_value"] : string list) iis in
  let actual_storage = Test.get_storage_of_address address_indice in

  // INDICE Increment(1)
  let () = Test.log("call Increment entrypoint of INDICE smart contract") in
  let () = Test.transfer_to_contract_exn indice_contract (Increment(1)) 0mutez in
  let inc_actual_storage = Test.get_storage indice_taddress in
  let () = Test.log(inc_actual_storage) in
  let () = assert(inc_actual_storage = indice_initial_storage + 1) in

  // INDICE Decrement(2)
  let () = Test.log("call Decrement entrypoint of INDICE smart contract") in
  let () = Test.transfer_to_contract_exn indice_contract (Decrement(2)) 0mutez in
  let dec_actual_storage = Test.get_storage indice_taddress in
  let () = Test.log(dec_actual_storage) in
  let () = assert(dec_actual_storage = inc_actual_storage - 2) in

  // deploy ADVISOR contract 
  let () = Test.log("deploy ADVISOR smart contract") in
  let advisor_initial_storage : ADVISOR.advisorStorage = {indiceAddress=address_indice; algorithm=(fun(i : int) -> if i < 10 then True else False); result=False} in
  let ais = Test.run (fun (x:ADVISOR.advisorStorage) -> x) advisor_initial_storage in
  //let advisor_contract_path = "advisor.mligo" in //"views_hangzhou/cameligo/advisor.mligo" in
  //let (address_advisor, code_advisor, _) = Test.originate_from_file advisor_contract_path "advisorMain" ([] : string list) ais 0tez in
  //let advisor_taddress = (Test.cast_address address_advisor : (ADVISOR.advisorEntrypoints,ADVISOR.advisorStorage) typed_address) in
  //let advisor_contract = Test.to_contract advisor_taddress in
  let (address_advisor, advisor_taddress, advisor_contract) : address * (ADVISOR.advisorEntrypoints, ADVISOR.advisorStorage) typed_address * ADVISOR.advisorEntrypoints contract = 
    originate_from_file "advisor.mligo" "advisorMain" ([] : string list) ais in

  // ADVISOR call ExecuteAlgorithm
  let () = Test.log("call ExecuteAlgorithm entrypoint of ADVISOR smart contract") in
  let () = Test.transfer_to_contract_exn advisor_contract (ExecuteAlgorithm(unit)) 0mutez in
  let advisor_modified_storage = Test.get_storage advisor_taddress in
  let () = Test.log(advisor_modified_storage) in
  let () = assert(advisor_modified_storage.result = True) in

  // ADVISOR call ChangeAlgorithm
  let () = Test.log("call ChangeAlgorithm entrypoint of ADVISOR smart contract") in
  let new_algo : int -> bool = (fun(i : int) -> if i < 3 then True else False) in
  let () = Test.transfer_to_contract_exn advisor_contract (ChangeAlgorithm(new_algo)) 0mutez in
  let advisor_modified_storage2 = Test.get_storage advisor_taddress in
  //let () = Test.log(advisor_modified_storage2.algorithm) in

  // ADVISOR call ExecuteAlgorithm
  let () = Test.log("call ExecuteAlgorithm entrypoint of ADVISOR smart contract") in
  let () = Test.transfer_to_contract_exn advisor_contract (ExecuteAlgorithm(unit)) 0mutez in
  let advisor_modified_storage3 = Test.get_storage advisor_taddress in
  let () = Test.log(advisor_modified_storage3) in
  assert(advisor_modified_storage3.result = False)


let test_e2e = _test



