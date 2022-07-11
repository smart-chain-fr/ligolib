#import "../../../contracts/cameligo/oracle/main.mligo" "ORACLE"
#import "../../../contracts/cameligo/oracle/types.mligo" "TYPES"

let bootstrap =
    (* Boostrapping accounts *)
    let () = Test.reset_state 5n ([] : tez list) in
    let elon: address = Test.nth_bootstrap_account 0 in
    let jeff: address = Test.nth_bootstrap_account 1 in
    let alice: address = Test.nth_bootstrap_account 2 in
    let bob: address = Test.nth_bootstrap_account 3 in
    let james: address = Test.nth_bootstrap_account 4 in

    (* Boostrapping storage *)
    let init_storage : TYPES.storage = {
        isPaused = false;
        manager = elon;
        signer = jeff;
        events = (Map.empty : (nat, TYPES.oracleEventType) map);
        events_index = 0n;
    } in

    (* Boostrapping Oracle contract *)
    let oraclePath = "./contracts/cameligo/oracle/main.mligo" in
    let iBis = Test.run (fun (x : TYPES.storage) -> x) init_storage in
    let (oracle_address, _, _) = Test.originate_from_file oraclePath "main" (["getStatus"] : string list) iBis 0tez in
    let oracle_taddress = (Test.cast_address oracle_address : (TYPES.action,TYPES.storage) typed_address) in
    let oracle_contract = Test.to_contract oracle_taddress in
    
    (oracle_contract, oracle_taddress, elon, jeff, alice, bob, james)

// let bootstrap_with_event =
//     (* Boostrapping accounts *)
//     let () = Test.reset_state 5n ([] : tez list) in
//     let elon: address = Test.nth_bootstrap_account 0 in
//     let jeff: address = Test.nth_bootstrap_account 1 in
//     let alice: address = Test.nth_bootstrap_account 2 in
//     let bob: address = Test.nth_bootstrap_account 3 in
//     let james: address = Test.nth_bootstrap_account 4 in

//     (* Boostrapping Event storage *)
//     let init_event_storage : TYPES.oracleEventType = {
//         name = "Event Name";
//         videogame= "Videogame Name";
//         begin_at= Tezos.get_now() + 2000;
//         end_at= Tezos.get_now() + 4000;
//         modified_at= Tezos.get_now();
//         opponents = { teamOne = "Team ONE"; teamTwo = "Team TWO"};
//         isFinished = false;
//         isDraw = None;
//         isTeamOneWin = None;
//         startBetTime = Tezos.get_now();
//         closedBetTime = Tezos.get_now() + 1000;
//         betsTeamOne = (Map.empty : (address, tez) map);
//         betsTeamOne_index = 0n;
//         betsTeamTwo = (Map.empty : (address, tez) map);
//         betsTeamTwo_index = 0n;
//         closedTeamOneRate = None;
//     } in

//     (* Boostrapping storage *)
//     let init_storage : TYPES.storage = {
//         isPaused = false;
//         manager = elon;
//         signer = jeff;
//         events = (Map.literal [(1n, init_event_storage); (2n, init_event_storage)]);
//         events_index = 0n;
//     } in

//     (* Boostrapping Oracle contract *)
//     let oraclePath = "./contracts/cameligo/oracle/main.mligo" in
//     let iBis = Test.run (fun (x : TYPES.storage) -> x) init_storage in
//     let (oracle_address, _, _) = Test.originate_from_file oraclePath "main" (["getStatus"] : string list) iBis 0tez in
//     let oracle_taddress = (Test.cast_address oracle_address : (TYPES.action,TYPES.storage) typed_address) in
//     let oracle_contract = Test.to_contract oracle_taddress in
    
//     (oracle_contract, oracle_taddress, elon, jeff, alice, bob, james)
