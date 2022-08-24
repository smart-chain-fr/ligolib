#import "../../../contracts/cameligo/betting/callback/main.mligo" "CALLBACK"
#import "../../../contracts/cameligo/betting/main.mligo" "BETTING"
#import "../../../contracts/cameligo/betting/types.mligo" "TYPES"

let plainTimestamp : timestamp = ("1970-01-01T00:00:01Z" : timestamp)

let primaryEvent : TYPES.eventType =
    {
        name = "First Event";
        videogame = "Videogame ONE";
        begin_at = plainTimestamp;
        end_at = plainTimestamp + 4096;
        modified_at = plainTimestamp;
        opponents = { teamOne = "Team ONE"; teamTwo = "Team TWO"};
        isFinalized = false;
        isDraw = (None : bool option);
        isTeamOneWin = (None : bool option);
        startBetTime = plainTimestamp;
        closedBetTime = plainTimestamp + 1024;
    }

let secondaryEvent : TYPES.eventType =
    {
        name = "Secondary Event";
        videogame = "Videogame TWO";
        begin_at = plainTimestamp;
        end_at = plainTimestamp + 4096;
        modified_at = plainTimestamp;
        opponents = { teamOne = "Team THREE"; teamTwo = "Team FOUR"};
        isFinalized = false;
        isDraw = (None : bool option);
        isTeamOneWin = (None : bool option);
        startBetTime = plainTimestamp;
        closedBetTime = plainTimestamp + 1024;
    }

let callbackInitStorage : CALLBACK.storage =
    {
        name = "";
        videogame = "";
        begin_at = plainTimestamp + 2048;
        end_at = plainTimestamp + 4096;
        modified_at = plainTimestamp;
        opponents = { teamOne = ""; teamTwo = ""};
        isFinalized = false;
        isDraw = (None : bool option);
        isTeamOneWin = (None : bool option);
        startBetTime = plainTimestamp + 360;
        closedBetTime = plainTimestamp + 1024;
        betsTeamOne = (Map.empty : (address, tez) map);
        betsTeamOne_index = 0n;
        betsTeamOne_total = 0mutez;
        betsTeamTwo = (Map.empty : (address, tez) map);
        betsTeamTwo_index = 0n;
        betsTeamTwo_total = 0mutez;
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

    let initBetConfig : TYPES.betConfigType = {
        isBettingPaused = false;
        isEventCreationPaused = false;
        minBetAmount = 1tez;
        retainedProfitQuota = 0n;
    } in
    
    (* Boostrapping storage *)
    let init_storage : TYPES.storage = {
        manager = elon;
        oracleAddress = jeff;
        betConfig = initBetConfig;
        events = (Map.empty : (nat, TYPES.eventType) map);
        events_bets = (Map.empty : (nat, TYPES.eventBets) map);
        events_index = 0n;
        metadata = (Map.empty : (string, bytes) map);
    } in

    (* Boostrapping BETTING contract *)
    let bettingPath = "contracts/cameligo/betting/main.mligo" in
    let iBis = Test.run (fun (x : TYPES.storage) -> x) init_storage in
    let (betting_address, _, _) = Test.originate_from_file bettingPath "main" (["getManager"; "getOracleAddress"; "getBettingStatus"; "getEventCreationStatus"; "getEvent"] : string list) iBis 0mutez in
    let betting_taddress = (Test.cast_address betting_address : (TYPES.action,TYPES.storage) typed_address) in
    let betting_contract = Test.to_contract betting_taddress in
    
    (betting_contract, betting_taddress, elon, jeff, alice, bob, james)

let bootstrap_callback =
    let bettingPath = "contracts/cameligo/betting/callback/main.mligo" in
    let iTres = Test.run (fun (x : CALLBACK.storage) -> x) callbackInitStorage in
    let (callback_addr, _, _) = Test.originate_from_file bettingPath "main" ([] : string list) iTres 0mutez in
    let callback_taddress = (Test.cast_address callback_addr : (CALLBACK.action, CALLBACK.storage) typed_address) in
    let callback_contract = Test.to_contract callback_taddress in
    (callback_contract, callback_taddress, callback_addr)