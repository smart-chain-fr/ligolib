#import "../../../contracts/cameligo/betting/callback/main.mligo" "CALLBACK"
#import "../../../contracts/cameligo/betting/main.mligo" "BETTING"
#import "../../../contracts/cameligo/betting/types.mligo" "TYPES"
#import "betting_callback.mligo" "HELPER_betting_callback"

let plainTimestamp : timestamp = ("1970-01-01T00:00:01Z" : timestamp)

let bootstrap () =
  (* Boostrapping accounts *)
  let () = Test.reset_state 6n ([] : tez list) in
  let _baker: address = Test.nth_bootstrap_account 0 in
  let elon:   address = Test.nth_bootstrap_account 1 in
  let jeff:   address = Test.nth_bootstrap_account 2 in
  let alice:  address = Test.nth_bootstrap_account 3 in
  let bob:    address = Test.nth_bootstrap_account 4 in
  let james:  address = Test.nth_bootstrap_account 5 in

  let initBetConfig : TYPES.bet_config_type = {
    isBettingPaused       = false;
    isEventCreationPaused = false;
    minBetAmount          = 1tez;
    retainedProfitQuota   = 10n;
  } in
  
  (* Boostrapping storage *)
  let init_storage : TYPES.storage = {
    manager       = elon;
    oracleAddress = jeff;
    betConfig     = initBetConfig;
    events        = (Big_map.empty : (nat, TYPES.event_type) big_map);
    events_bets   = (Big_map.empty : (nat, TYPES.event_bets) big_map);
    events_index  = 0n;
    metadata      = (Map.empty : (string, bytes) map);
  } in

  (* Boostrapping BETTING contract *)
  let bettingPath = "contracts/cameligo/betting/main.mligo" in
  let iBis = Test.run (fun (x : TYPES.storage) -> x) init_storage in
  let (betting_address, _, _) = Test.originate_from_file bettingPath "main" (["getManager"; "getOracleAddress"; "getBettingStatus"; "getEventCreationStatus"; "getEvent"] : string list) iBis 0mutez in
  let betting_taddress = (Test.cast_address betting_address : (TYPES.action,TYPES.storage) typed_address) in
  let betting_contract = Test.to_contract betting_taddress in
  
  (betting_address, betting_contract, betting_taddress, elon, jeff, alice, bob, james)

let bootstrap_betting_callback (bettingAddr : address) =
    let betting_callback = HELPER_betting_callback.originate_from_file(HELPER_betting_callback.base_storage(bettingAddr)) in    
    betting_callback
    