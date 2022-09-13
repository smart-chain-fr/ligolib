#import "../../contracts/cameligo/betting/main.mligo" "BETTING"
#import "../../contracts/cameligo/betting/types.mligo" "TYPES"
#import "helpers/bootstrap.mligo" "BOOTSTRAP"
#import "helpers/helper.mligo" "HELPER"
#import "helpers/assert.mligo" "ASSERT"

(**
 *  Basic Win Reward Test
 *)
let test_win_basic_team1_should_work = 
  //Given
  let (betting_contract, betting_taddress, elon, _, alice, bob, mike) = BOOTSTRAP.bootstrap() in
  let _ = HELPER.trscAddEvent (betting_contract, elon, BOOTSTRAP.primaryEvent) in
  let _ = HELPER.trscAddBet (betting_contract, alice, 0n, (true  : bool), 800000000000mutez) in
  let _ = HELPER.trscAddBet (betting_contract, bob,   0n, (true  : bool), 800000000000mutez) in
  let _ = HELPER.trscAddBet (betting_contract, mike,  0n, (false : bool), 800000000000mutez) in
  let _ = HELPER.trscUpdateEvent (betting_contract, elon, 0n, BOOTSTRAP.finalized_event_team1_win) in
  let storage = Test.get_storage(betting_taddress) in
  let quota_left : nat = abs(100n - storage.betConfig.retainedProfitQuota) in
  let expected_alice_balance = Test.get_balance(alice) + (800000000000mutez + 400000000000mutez) * quota_left / 100n in
  let expected_bob_balance   = Test.get_balance(bob)   + (800000000000mutez + 400000000000mutez) * quota_left / 100n in
  let expected_mike_balance  = Test.get_balance(mike) in
  //When
  let _ = HELPER.trscFinalizeBet (betting_contract, elon, 0n) in
  //Then
  let _ = assert (expected_alice_balance = Test.get_balance(alice)) in
  let _ = assert (expected_bob_balance   = Test.get_balance(bob)) in
  let _ = assert (expected_mike_balance  = Test.get_balance(mike)) in
  "OK"


(**
 *  Basic Draw Reward Test
 *)
let test_draw_should_work = 
  //Given
  let (betting_contract, betting_taddress, elon, _, alice, bob, mike) = BOOTSTRAP.bootstrap() in
  let _ = HELPER.trscAddEvent (betting_contract, elon, BOOTSTRAP.primaryEvent) in
  let _ = HELPER.trscAddBet (betting_contract, alice, 0n, (true  : bool), 800000000000mutez) in
  let _ = HELPER.trscAddBet (betting_contract, bob,   0n, (true  : bool), 800000000000mutez) in
  let _ = HELPER.trscAddBet (betting_contract, mike,  0n, (false : bool), 800000000000mutez) in
  let _ = HELPER.trscUpdateEvent (betting_contract, elon, 0n, BOOTSTRAP.finalized_event_draw) in
  let storage = Test.get_storage(betting_taddress) in
  let quota_left : nat = abs(100n - storage.betConfig.retainedProfitQuota) in
  let expected_alice_balance = Test.get_balance(alice) + 800000000000mutez * quota_left / 100n in
  let expected_bob_balance   = Test.get_balance(bob)   + 800000000000mutez * quota_left / 100n in
  let expected_mike_balance  = Test.get_balance(mike)  + 800000000000mutez * quota_left / 100n in
  //When
  let _ = HELPER.trscFinalizeBet (betting_contract, elon, 0n) in
  //Then
  let _ = assert (expected_alice_balance = Test.get_balance(alice)) in
  let _ = assert (expected_bob_balance   = Test.get_balance(bob)) in
  let _ = assert (expected_mike_balance  = Test.get_balance(mike)) in
  "OK"


(**
 *  Weighted Win Reward Test
 *)
let test_win_weighted_team1_should_work = 
  //Given
  let (betting_contract, betting_taddress, elon, _, alice, bob, mike) = BOOTSTRAP.bootstrap() in
  let _ = HELPER.trscAddEvent (betting_contract, elon, BOOTSTRAP.primaryEvent) in
  let _ = HELPER.trscAddBet (betting_contract, alice, 0n, (true  : bool), 800000000000mutez) in
  let _ = HELPER.trscAddBet (betting_contract, bob,   0n, (true  : bool), 400000000000mutez) in
  let _ = HELPER.trscAddBet (betting_contract, mike,  0n, (false : bool), 600000000000mutez) in
  let _ = HELPER.trscUpdateEvent (betting_contract, elon, 0n, BOOTSTRAP.finalized_event_team1_win) in
  let storage = Test.get_storage(betting_taddress) in
  let quota_left : nat = abs(100n - storage.betConfig.retainedProfitQuota) in
  let expected_alice_balance = Test.get_balance(alice) + (800000000000mutez + 400000000000mutez) * quota_left / 100n in
  let expected_bob_balance   = Test.get_balance(bob)   + (400000000000mutez + 200000000000mutez) * quota_left / 100n in
  //When
  let _ = HELPER.trscFinalizeBet (betting_contract, elon, 0n) in
  //Then
  let alice_bal_error : tez = match (expected_alice_balance - Test.get_balance(alice)) with
    | Some b -> b 
    | None   -> failwith "Weighted Win Reward Test Fails"
  in
  let bob_bal_error : tez = match (expected_bob_balance - Test.get_balance(bob)) with
    | Some b -> b 
    | None   -> failwith "Weighted Win Reward Test Fails"
  in
  let _ = assert (alice_bal_error < 1tez) in
  let _ = assert (bob_bal_error   < 1tez) in
  "OK"


(**
 *  Weighted Win Reward Test Team 2
 *)
let test_win_weighted_team2_should_work = 
  //Given
  let (betting_contract, betting_taddress, elon, _, alice, bob, mike) = BOOTSTRAP.bootstrap() in
  let _ = HELPER.trscAddEvent (betting_contract, elon, BOOTSTRAP.primaryEvent) in
  let _ = HELPER.trscAddBet (betting_contract, alice, 0n, (true  : bool), 30000tez) in
  let _ = HELPER.trscAddBet (betting_contract, mike,  0n, (false : bool), 60000tez) in
  let _ = HELPER.trscAddBet (betting_contract, bob,   0n, (false : bool), 30000tez) in
  let _ = HELPER.trscUpdateEvent (betting_contract, elon, 0n, BOOTSTRAP.finalized_event_team2_win) in
  let storage = Test.get_storage(betting_taddress) in
  let quota_left : nat = abs(100n - storage.betConfig.retainedProfitQuota) in
  let expected_mike_balance = Test.get_balance(mike) + (60000tez + 20000tez) * quota_left / 100n in
  let expected_bob_balance = Test.get_balance(bob) + (30000tez + 10000tez) * quota_left / 100n in
  //When
  let _ = HELPER.trscFinalizeBet (betting_contract, elon, 0n) in
  //Then
  let mike_bal_error : tez = match (expected_mike_balance - Test.get_balance(mike)) with
    | Some b -> b 
    | None   -> failwith "Double Weighted Win Reward Test Team 2 Fails"
  in
  let bob_bal_error : tez = match (expected_bob_balance - Test.get_balance(bob)) with
    | Some b -> b 
    | None   -> failwith "Double Weighted Win Reward Test Team 2 Fails"
  in
  let _ = assert (mike_bal_error < 1tez) in
  let _ = assert (bob_bal_error < 1tez) in
  "OK"