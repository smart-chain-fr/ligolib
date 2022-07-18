#import "../../../contracts/cameligo/betting/main.mligo" "ORACLE"
#import "../../../contracts/cameligo/betting/types.mligo" "TYPES"
#import "../../../contracts/cameligo/betting/callback/main.mligo" "CALLBACK"

let primaryEvent : TYPES.eventType =
    {
        name = "First Event";
        videogame= "Videogame ONE";
        begin_at= Tezos.get_now() + 2000;
        end_at= Tezos.get_now() + 4000;
        modified_at= Tezos.get_now();
        opponents = { teamOne = "Team ONE"; teamTwo = "Team TWO"};
        isFinished = false;
        isDraw = None;
        isTeamOneWin = None;
        startBetTime = Tezos.get_now();
        closedBetTime = Tezos.get_now() + 1000;
        betsTeamOne = (Map.empty : (address, tez) map);
        betsTeamOne_index = 0n;
        betsTeamTwo = (Map.empty : (address, tez) map);
        betsTeamTwo_index = 0n;
        closedTeamOneRate = None;
    }

let secondaryEvent : TYPES.eventType =
    {
        name = "Secondary Event";
        videogame= "Videogame TWO";
        begin_at= Tezos.get_now() + 2000;
        end_at= Tezos.get_now() + 4000;
        modified_at= Tezos.get_now();
        opponents = { teamOne = "Team THREE"; teamTwo = "Team FOUR"};
        isFinished = false;
        isDraw = None;
        isTeamOneWin = None;
        startBetTime = Tezos.get_now();
        closedBetTime = Tezos.get_now() + 1000;
        betsTeamOne = (Map.empty : (address, tez) map);
        betsTeamOne_index = 0n;
        betsTeamTwo = (Map.empty : (address, tez) map);
        betsTeamTwo_index = 0n;
        closedTeamOneRate = None;
    }

let callbackInitStorage : CALLBACK.storage =
    {
        name = "";
        videogame= "";
        begin_at= Tezos.get_now() + 2000;
        end_at= Tezos.get_now() + 4000;
        modified_at= Tezos.get_now();
        opponents = { teamOne = ""; teamTwo = ""};
        isFinished = false;
        isDraw = None;
        isTeamOneWin = None;
        startBetTime = Tezos.get_now();
        closedBetTime = Tezos.get_now() + 1000;
        betsTeamOne = (Map.empty : (address, tez) map);
        betsTeamOne_index = 0n;
        betsTeamTwo = (Map.empty : (address, tez) map);
        betsTeamTwo_index = 0n;
        closedTeamOneRate = None;
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
        minBetAmount = 1n;
        minPeriodToBet = 1n;
        maxBetDifference = 1n;
        retainedProfitQuota = 0n;
    } in
    
    (* Boostrapping storage *)
    let init_storage : TYPES.storage = {
        manager = elon;
        oracleAddress = jeff;
        betConfig = initBetConfig;
        retainedProfits = 0tez;
        events = (Map.empty : (nat, TYPES.eventType) map);
        events_index = 0n;
        metadata = (Map.empty : (string, bytes) map);
    } in

    (* Boostrapping Oracle contract *)
    let bettingPath = "./contracts/cameligo/betting/main.mligo" in
    let iBis = Test.run (fun (x : TYPES.storage) -> x) init_storage in
    let (betting_address, _, _) = Test.originate_from_file bettingPath "main" (["getManager"; "getOracleAddress"; "getStatus"] : string list) iBis 0tez in
    let betting_taddress = (Test.cast_address betting_address : (TYPES.action,TYPES.storage) typed_address) in
    let betting_contract = Test.to_contract betting_taddress in
    
    (betting_contract, betting_taddress, elon, jeff, alice, bob, james)

let bootstrap_callback =
    let bettingPath = "./contracts/cameligo/betting/callback/main.mligo" in
    let iTres = Test.run (fun (x : CALLBACK.storage) -> x) callbackInitStorage in
    let (callback_addr, _, _) = Test.originate_from_file bettingPath "main" ([] : string list) iTres 0tez in
    let callback_taddress = (Test.cast_address callback_addr : (CALLBACK.action, CALLBACK.storage) typed_address) in
    let callback_contract = Test.to_contract callback_taddress in
    (callback_contract, callback_taddress, callback_addr)