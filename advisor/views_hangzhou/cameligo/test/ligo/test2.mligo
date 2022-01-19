#import "../../advisor.mligo" "ADVISOR"
#import "indice_no_view.mligo" "DUMMY"

let assert_string_failure (res : test_exec_result) (expected : string) : unit =
  let expected = Test.eval expected in
  match res with
  | Fail (Rejected (actual,_)) -> assert (Test.michelson_equal actual expected)
  | Fail (Other) -> failwith "contract failed for an unknown reason"
  | Success -> failwith "bad price check"

let test =
  
  // deploy DUMMY smart contract 
  let indice_initial_storage = 4 in
  let () = Test.log("deploy DUMMY smart contract") in
  let iis = Test.run (fun (x:DUMMY.indiceStorage) -> x) indice_initial_storage in
  // path relative to where the command run test in runned
  let indice_contract_path = "test/ligo/indice_no_view.mligo" in
  let (address_indice, code_indice, _) = Test.originate_from_file indice_contract_path "indiceMain" ([] : string list) iis 0tez in
  let actual_storage = Test.get_storage_of_address address_indice in
  let indice_taddress = (Test.cast_address address_indice : (DUMMY.indiceEntrypoints,DUMMY.indiceStorage) typed_address) in
  let indice_contract = Test.to_contract indice_taddress in

  // INDICE Increment(1)
  let () = Test.log("call Increment entrypoint of DUMMY smart contract") in
  let () = Test.transfer_to_contract_exn indice_contract (Increment(1)) 0mutez in
  let inc_actual_storage = Test.get_storage indice_taddress in
  let () = Test.log(inc_actual_storage) in
  let () = assert(inc_actual_storage = indice_initial_storage + 1) in

  // INDICE Decrement(2)
  let () = Test.log("call Decrement entrypoint of DUMMY smart contract") in
  let () = Test.transfer_to_contract_exn indice_contract (Decrement(2)) 0mutez in
  let dec_actual_storage = Test.get_storage indice_taddress in
  let () = Test.log(dec_actual_storage) in
  let () = assert(dec_actual_storage = inc_actual_storage - 2) in

  // deploy ADVISOR contract 
  let () = Test.log("deploy ADVISOR smart contract") in
  let advisor_initial_storage : ADVISOR.advisorStorage = {indiceAddress=address_indice; algorithm=(fun(i : int) -> if i < 10 then True else False); result=False} in
  let ais = Test.run (fun (x:ADVISOR.advisorStorage) -> x) advisor_initial_storage in
  let advisor_contract_path = "advisor.mligo" in //"views_hangzhou/cameligo/advisor.mligo" in
  let (address_advisor, code_advisor, _) = Test.originate_from_file advisor_contract_path "advisorMain" ([] : string list) ais 0tez in
  let advisor_taddress = (Test.cast_address address_advisor : (ADVISOR.advisorEntrypoints,ADVISOR.advisorStorage) typed_address) in
  let advisor_contract = Test.to_contract advisor_taddress in

  // ADVISOR call ExecuteAlgorithm
  let () = Test.log("call ExecuteAlgorithm entrypoint of ADVISOR smart contract (should fail because DUMMY has no view)") in
  let result : test_exec_result = Test.transfer_to_contract advisor_contract (ExecuteAlgorithm(unit)) 0mutez in
  let () = assert_string_failure result "View indice_value not found" in
  let advisor_modified_storage = Test.get_storage advisor_taddress in
  let () = Test.log(advisor_modified_storage) in
  assert(advisor_modified_storage.result = advisor_initial_storage.result)

