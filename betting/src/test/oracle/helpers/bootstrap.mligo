#import "../../../contracts/cameligo/oracle/main.mligo" "ORACLE"
#import "../../../contracts/cameligo/oracle/types.mligo" "TYPES"
#import "../../../contracts/cameligo/oracle/callback/main.mligo" "CALLBACK"

let primaryEvent : TYPES.eventType =
    {
        name = "First Event";
        videogame= "Videogame ONE";
        begin_at= Tezos.get_now() + 2000;
        end_at= Tezos.get_now() + 4000;
        modified_at= Tezos.get_now();
        opponents = { teamOne = "Team ONE"; teamTwo = "Team TWO"};
        isFinalized = false;
        isFinished = false;
        isDraw = (None : bool option);
        isTeamOneWin = (None : bool option);
    }

let secondaryEvent : TYPES.eventType =
    {
        name = "Secondary Event";
        videogame= "Videogame TWO";
        begin_at= Tezos.get_now() + 2000;
        end_at= Tezos.get_now() + 4000;
        modified_at= Tezos.get_now();
        opponents = { teamOne = "Team THREE"; teamTwo = "Team FOUR"};
        isFinalized = false;
        isFinished = false;
        isDraw = (None : bool option);
        isTeamOneWin = (None : bool option);
    }

let callbackInitStorage : CALLBACK.storage =
    {
        name = "";
        videogame= "";
        begin_at= Tezos.get_now() + 2000;
        end_at= Tezos.get_now() + 4000;
        modified_at= Tezos.get_now();
        opponents = { teamOne = ""; teamTwo = ""};
        isFinalized = false;
        isFinished = false;
        isDraw = (None : bool option);
        isTeamOneWin = (None : bool option);
        metadata = (Map.empty : (string, bytes) map);
    }

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
        events = (Map.empty : (nat, TYPES.eventType) map);
        events_index = 0n;
        metadata = (Map.empty : (string, bytes) map);
    } in

    (* Boostrapping Oracle contract *)
    let oraclePath = "contracts/cameligo/oracle/main.mligo" in
    let iBis = Test.run (fun (x : TYPES.storage) -> x) init_storage in
    let (oracle_address, _, _) = Test.originate_from_file oraclePath "main" (["getManager"; "getSigner"; "getStatus"] : string list) iBis 0tez in
    let oracle_taddress = (Test.cast_address oracle_address : (TYPES.action,TYPES.storage) typed_address) in
    let oracle_contract = Test.to_contract oracle_taddress in
    
    (oracle_contract, oracle_taddress, elon, jeff, alice, bob, james)

let bootstrap_callback =
    let oraclePath = "contracts/cameligo/oracle/callback/main.mligo" in
    let iTres = Test.run (fun (x : CALLBACK.storage) -> x) callbackInitStorage in
    let (callback_addr, _, _) = Test.originate_from_file oraclePath "main" ([] : string list) iTres 0tez in
    let callback_taddress = (Test.cast_address callback_addr : (CALLBACK.action, CALLBACK.storage) typed_address) in
    let callback_contract = Test.to_contract callback_taddress in
    (callback_contract, callback_taddress, callback_addr)