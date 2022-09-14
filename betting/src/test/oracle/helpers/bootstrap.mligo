#import "../../../contracts/cameligo/oracle/main.mligo" "ORACLE"
#import "../../../contracts/cameligo/oracle/types.mligo" "TYPES"
#import "../../../contracts/cameligo/oracle/callback/main.mligo" "CALLBACK"
#import "oracle_callback.mligo" "HELPER_oracle_callback"

let plainTimestamp : timestamp = ("1970-01-01T00:00:01Z" : timestamp)

let primaryEvent : TYPES.event_type =
    {
        name = "First Event";
        videogame = "Videogame ONE";
        begin_at = plainTimestamp;
        end_at = plainTimestamp + 4096;
        modified_at = plainTimestamp;
        opponents = { team_one = "Team ONE"; team_two = "Team TWO"};
        is_finalized = false;
        is_draw = (None : bool option);
        is_team_one_win = (None : bool option);
    }

let secondaryEvent : TYPES.event_type =
    {
        name = "Secondary Event";
        videogame = "Videogame TWO";
        begin_at = plainTimestamp;
        end_at = plainTimestamp + 4096;
        modified_at = plainTimestamp;
        opponents = { team_one = "Team THREE"; team_two = "Team FOUR"};
        is_finalized = false;
        is_draw = (None : bool option);
        is_team_one_win = (None : bool option);
    }

let callbackInitStorage : CALLBACK.storage =
    {
        name = "";
        videogame = "";
        begin_at = plainTimestamp + 2000;
        end_at = plainTimestamp + 4000;
        modified_at = plainTimestamp;
        opponents = { team_one = ""; team_two = ""};
        is_finalized = false;
        is_draw = (None : bool option);
        is_team_one_win = (None : bool option);
        metadata = (Map.empty : (string, bytes) map);
    }

let bootstrap_oracle () =
    (* Boostrapping accounts *)
    let () = Test.reset_state 6n ([] : tez list) in
    let _baker: address = Test.nth_bootstrap_account 0 in
    let elon: address = Test.nth_bootstrap_account 1 in
    let jeff: address = Test.nth_bootstrap_account 2 in
    let alice: address = Test.nth_bootstrap_account 3 in
    let bob: address = Test.nth_bootstrap_account 4 in
    let james: address = Test.nth_bootstrap_account 5 in


    (* Boostrapping storage *)
    let init_storage : TYPES.storage = {
        isPaused = false;
        manager = elon;
        signer = jeff;
        events = (Map.empty : (nat, TYPES.event_type) map);
        events_index = 0n;
        metadata = (Map.empty : (string, bytes) map);
    } in

    (* Boostrapping Oracle contract *)
    let oraclePath = "contracts/cameligo/oracle/main.mligo" in
    let iBis = Test.run (fun (x : TYPES.storage) -> x) init_storage in
    let (oracle_address, _, _) = Test.originate_from_file oraclePath "main" (["getManager"; "getSigner"; "getStatus"; "getEvent"] : string list) iBis 0mutez in
    let oracle_taddress = (Test.cast_address oracle_address : (TYPES.action,TYPES.storage) typed_address) in
    let oracle_contract = Test.to_contract oracle_taddress in
    
    (oracle_contract, oracle_taddress, elon, jeff, alice, bob, james)

let bootstrap_oracle_callback () =
    let oracle_callback = HELPER_oracle_callback.originate_from_file(HELPER_oracle_callback.base_storage) in    
    oracle_callback
