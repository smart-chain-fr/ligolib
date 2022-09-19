#import "../../src/contracts/cameligo/betting/errors.mligo" "Errors"
#import "helpers/bootstrap.mligo" "Bootstrap"
#import "helpers/helper.mligo" "Helper"
#import "helpers/assert.mligo" "Assert"
#import "helpers/events.mligo" "Events"
#import "helpers/log.mligo" "Log"

let () = Log.describe("[Betting - FinalizeBet] test suite")

(**
 *  Basic Win Reward Test
 *)
let test_win_basic_team1_should_work = 
  //Given
  let (_, betting_contract, betting_taddress, elon, _, alice, bob, mike) = Bootstrap.bootstrap() in
  let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
  let () = Helper.trsc_add_bet_success (betting_contract, alice, 0n, (true  : bool), 800000000000mutez) in
  let () = Helper.trsc_add_bet_success (betting_contract, bob,   0n, (true  : bool), 800000000000mutez) in
  let () = Helper.trsc_add_bet_success (betting_contract, mike,  0n, (false : bool), 800000000000mutez) in
  let () = Helper.trsc_update_event_success (betting_contract, elon, 0n, Events.finalized_event_team1_win) in
  let storage = Test.get_storage(betting_taddress) in
  let quota_left : nat = abs(100n - storage.bet_config.retained_profit_quota) in
  let expected_alice_balance = Test.get_balance(alice) + (800000000000mutez + 400000000000mutez) * quota_left / 100n in
  let expected_bob_balance   = Test.get_balance(bob)   + (800000000000mutez + 400000000000mutez) * quota_left / 100n in
  let expected_mike_balance  = Test.get_balance(mike) in
  //When
  let () = Helper.trsc_finalize_bet_success (betting_contract, elon, 0n) in
  //Then
  let () = assert (expected_alice_balance = Test.get_balance(alice)) in
  let () = assert (expected_bob_balance   = Test.get_balance(bob)) in
  let () = assert (expected_mike_balance  = Test.get_balance(mike)) in
  "OK"


(**
 *  Basic Draw Reward Test
 *)
let test_draw_should_work = 
  //Given
  let (_, betting_contract, betting_taddress, elon, _, alice, bob, mike) = Bootstrap.bootstrap() in
  let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
  let () = Helper.trsc_add_bet_success (betting_contract, alice, 0n, (true  : bool), 800000000000mutez) in
  let () = Helper.trsc_add_bet_success (betting_contract, bob,   0n, (true  : bool), 800000000000mutez) in
  let () = Helper.trsc_add_bet_success (betting_contract, mike,  0n, (false : bool), 800000000000mutez) in
  let () = Helper.trsc_update_event_success (betting_contract, elon, 0n, Events.finalized_event_draw) in
  let storage = Test.get_storage(betting_taddress) in
  let quota_left : nat = abs(100n - storage.bet_config.retained_profit_quota) in
  let expected_alice_balance = Test.get_balance(alice) + 800000000000mutez * quota_left / 100n in
  let expected_bob_balance   = Test.get_balance(bob)   + 800000000000mutez * quota_left / 100n in
  let expected_mike_balance  = Test.get_balance(mike)  + 800000000000mutez * quota_left / 100n in
  //When
  let () = Helper.trsc_finalize_bet_success (betting_contract, elon, 0n) in
  //Then
  let () = assert (expected_alice_balance = Test.get_balance(alice)) in
  let () = assert (expected_bob_balance   = Test.get_balance(bob)) in
  let () = assert (expected_mike_balance  = Test.get_balance(mike)) in
  "OK"


(**
 *  Weighted Win Reward Test
 *)
let test_win_weighted_team1_should_work = 
  //Given
  let (_, betting_contract, betting_taddress, elon, _, alice, bob, mike) = Bootstrap.bootstrap() in
  let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
  let () = Helper.trsc_add_bet_success (betting_contract, alice, 0n, (true  : bool), 800000000000mutez) in
  let () = Helper.trsc_add_bet_success (betting_contract, bob,   0n, (true  : bool), 400000000000mutez) in
  let () = Helper.trsc_add_bet_success (betting_contract, mike,  0n, (false : bool), 600000000000mutez) in
  let () = Helper.trsc_update_event_success (betting_contract, elon, 0n, Events.finalized_event_team1_win) in
  let storage = Test.get_storage(betting_taddress) in
  let quota_left : nat = abs(100n - storage.bet_config.retained_profit_quota) in
  let expected_alice_balance = Test.get_balance(alice) + (800000000000mutez + 400000000000mutez) * quota_left / 100n in
  let expected_bob_balance   = Test.get_balance(bob)   + (400000000000mutez + 200000000000mutez) * quota_left / 100n in
  //When
  let () = Helper.trsc_finalize_bet_success (betting_contract, elon, 0n) in
  //Then
  let alice_bal_error : tez = match (expected_alice_balance - Test.get_balance(alice)) with
    | Some b -> b 
    | None   -> failwith "Weighted Win Reward Test Fails"
  in
  let bob_bal_error : tez = match (expected_bob_balance - Test.get_balance(bob)) with
    | Some b -> b 
    | None   -> failwith "Weighted Win Reward Test Fails"
  in
  let () = assert (alice_bal_error < 1tez) in
  let () = assert (bob_bal_error   < 1tez) in
  "OK"


(**
 *  Weighted Win Reward Test Team 2
 *)
let test_win_weighted_team2_should_work = 
  //Given
  let (_, betting_contract, betting_taddress, elon, _, alice, bob, mike) = Bootstrap.bootstrap() in
  let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
  let () = Helper.trsc_add_bet_success (betting_contract, alice, 0n, (true  : bool), 30000tez) in
  let () = Helper.trsc_add_bet_success (betting_contract, mike,  0n, (false : bool), 60000tez) in
  let () = Helper.trsc_add_bet_success (betting_contract, bob,   0n, (false : bool), 30000tez) in
  let () = Helper.trsc_update_event_success (betting_contract, elon, 0n, Events.finalized_event_team2_win) in
  let storage = Test.get_storage(betting_taddress) in
  let quota_left : nat = abs(100n - storage.bet_config.retained_profit_quota) in
  let expected_mike_balance = Test.get_balance(mike) + (60000tez + 20000tez) * quota_left / 100n in
  let expected_bob_balance = Test.get_balance(bob) + (30000tez + 10000tez) * quota_left / 100n in
  //When
  let () = Helper.trsc_finalize_bet_success (betting_contract, elon, 0n) in
  //Then
  let mike_bal_error : tez = match (expected_mike_balance - Test.get_balance(mike)) with
    | Some b -> b 
    | None   -> failwith "Double Weighted Win Reward Test Team 2 Fails"
  in
  let bob_bal_error : tez = match (expected_bob_balance - Test.get_balance(bob)) with
    | Some b -> b 
    | None   -> failwith "Double Weighted Win Reward Test Team 2 Fails"
  in
  let () = assert (mike_bal_error < 1tez) in
  let () = assert (bob_bal_error < 1tez) in
  "OK"


(**
 *  Finalizing a bet two times should fail
 *)
let test_finalizing_bet_two_times_should_fail = 
  //Given
  let (_, betting_contract, _, elon, _, alice, _, mike) = Bootstrap.bootstrap() in
  let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
  let () = Helper.trsc_add_bet_success (betting_contract, alice, 0n, (true  : bool), 30000tez) in
  let () = Helper.trsc_add_bet_success (betting_contract, mike,  0n, (false : bool), 60000tez) in
  let () = Helper.trsc_update_event_success (betting_contract, elon, 0n, Events.finalized_event_team1_win) in
  //When
  let ret = Helper.trsc_update_event (betting_contract, elon, 0n, Events.finalized_event_team1_win) in
  //Then
  let () = Assert.string_failure ret Errors.bet_finished in
  "OK"


(**
 *  Claiming a bet two times should fail
 *)
let test_claim_bet_two_times_should_fail = 
  //Given
  let (_, betting_contract, _, elon, _, alice, _, mike) = Bootstrap.bootstrap() in
  let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
  let () = Helper.trsc_add_bet_success (betting_contract, alice, 0n, (true  : bool), 30000tez) in
  let () = Helper.trsc_add_bet_success (betting_contract, mike,  0n, (false : bool), 60000tez) in
  let () = Helper.trsc_update_event_success (betting_contract, elon, 0n, Events.finalized_event_team1_win) in
  let () = Helper.trsc_finalize_bet_success (betting_contract, elon, 0n) in
  //When
  let ret = Helper.trsc_finalize_bet (betting_contract, elon, 0n) in
  //Then
  let () = Assert.string_failure ret Errors.event_already_claimed in
  "OK"



(**
 *  Finalising a bet without outcome should fail
 *)
let test_finalizing_bet_without_outcome_should_fail = 
  //Given
  let (_, betting_contract, _, elon, _, alice, _, mike) = Bootstrap.bootstrap() in
  let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
  let () = Helper.trsc_add_bet_success (betting_contract, alice, 0n, (true  : bool), 1000tez) in
  let () = Helper.trsc_add_bet_success (betting_contract, mike,  0n, (false : bool), 1000tez) in
  //When
  let ret = Helper.trsc_finalize_bet (betting_contract, elon, 0n) in
  //Then
  let () = Assert.string_failure ret Errors.bet_not_finished in
  "OK"


(**
 *  Finalising a wrong Id
 *)
let test_finalizing_bet_with_wrong_id_should_fail = 
  //Given
  let (_, betting_contract, _, elon, _, alice, _, mike) = Bootstrap.bootstrap() in
  let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
  let () = Helper.trsc_add_bet_success (betting_contract, alice, 0n, (true  : bool), 1000tez) in
  let () = Helper.trsc_add_bet_success (betting_contract, mike,  0n, (false : bool), 1000tez) in
  let () = Helper.trsc_update_event_success (betting_contract, elon, 0n, Events.finalized_event_team1_win) in
  //When
  let ret = Helper.trsc_finalize_bet (betting_contract, elon, 1n) in
  //Then
  let () = Assert.string_failure ret Errors.no_event_id in
  "OK"


(**
 *  Winning without counterparty should refund
 *)
let test_winning_without_counterparty_refund_should_work = 
  //Given
  let (_, betting_contract, _betting_taddress, elon, _, alice, _, _) = Bootstrap.bootstrap() in
  let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
  let () = Helper.trsc_add_bet_success (betting_contract, alice, 0n, (true  : bool), 1000tez) in
  let () = Helper.trsc_update_event_success (betting_contract, elon, 0n, Events.finalized_event_team1_win) in
  let expected_alice_balance = Test.get_balance(alice) + 1000tez in
  //When
  let () = Helper.trsc_finalize_bet_success (betting_contract, elon, 0n) in
  //Then
  let () = assert (expected_alice_balance = Test.get_balance(alice)) in
  "OK"


(**
 *  Finalising an event not finished should fail
 *)
let test_finalizing_event_not_finished_should_fail = 
  //Given
  let (_, betting_contract, _, elon, _, alice, _, mike) = Bootstrap.bootstrap() in
  let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
  let () = Helper.trsc_add_bet_success (betting_contract, alice, 0n, (true  : bool), 1000tez) in
  let () = Helper.trsc_add_bet_success (betting_contract, mike,  0n, (false : bool), 1000tez) in
  let () = Helper.trsc_update_event_success (betting_contract, elon, 0n, Events.finalized_event_too_long) in
  //When
  let ret = Helper.trsc_finalize_bet (betting_contract, elon, 0n) in
  //Then
  let () = Assert.string_failure ret Errors.bet_period_not_finished in
  "OK"


(**
 *  Finalising an event without manager rights should fail
 *)
let test_finalizing_event_without_manager_rights_should_fail = 
  //Given
  let (_, betting_contract, _, elon, _, alice, _, _) = Bootstrap.bootstrap() in
  let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
  let () = Helper.trsc_add_bet_success (betting_contract, alice, 0n, (true  : bool), 1000tez) in
  let () = Helper.trsc_update_event_success (betting_contract, elon, 0n, Events.finalized_event_too_long) in
  //When
  let ret = Helper.trsc_finalize_bet (betting_contract, alice, 0n) in
  //Then
  let () = Assert.string_failure ret Errors.not_manager in
  "OK"