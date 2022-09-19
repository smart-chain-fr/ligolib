#import "../../../src/contracts/cameligo/oracle/types.mligo" "Types"
#import "../../../src/contracts/cameligo/oracle/callback/main.mligo" "Callback"
#import "callback.mligo" "Helper_Callback"

let plain_timestamp : timestamp = ("1970-01-01T00:00:01Z" : timestamp)

let primary_event : Types.event_type =
    {
        name = "First Event";
        videogame = "Videogame ONE";
        begin_at = plain_timestamp;
        end_at = plain_timestamp + 4096;
        modified_at = plain_timestamp;
        opponents = { team_one = "Team ONE"; team_two = "Team TWO"};
        is_finalized = false;
        is_draw = (None : bool option);
        is_team_one_win = (None : bool option);
    }

let secondary_event : Types.event_type =
    {
        name = "Secondary Event";
        videogame = "Videogame TWO";
        begin_at = plain_timestamp;
        end_at = plain_timestamp + 4096;
        modified_at = plain_timestamp;
        opponents = { team_one = "Team THREE"; team_two = "Team FOUR"};
        is_finalized = false;
        is_draw = (None : bool option);
        is_team_one_win = (None : bool option);
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
    let init_storage : Types.storage = {
        isPaused = false;
        manager = elon;
        signer = jeff;
        events = (Map.empty : (nat, Types.event_type) map);
        events_index = 0n;
        metadata = (Map.empty : (string, bytes) map);
    } in

    (* Boostrapping Oracle contract *)
    let oracle_path = "src/contracts/cameligo/oracle/main.mligo" in
    let iBis = Test.run (fun (x : Types.storage) -> x) init_storage in
    let (oracle_address, _, _) = Test.originate_from_file oracle_path "main" (["getManager"; "getSigner"; "getStatus"; "getEvent"] : string list) iBis 0mutez in
    let oracle_taddress = (Test.cast_address oracle_address : (Types.action,Types.storage) typed_address) in
    let oracle_contract = Test.to_contract oracle_taddress in
    
    (oracle_contract, oracle_taddress, elon, jeff, alice, bob, james)

let bootstrap_oracle_callback () =
    let oracle_callback = Helper_Callback.originate_from_file(Helper_Callback.base_storage) in    
    oracle_callback
