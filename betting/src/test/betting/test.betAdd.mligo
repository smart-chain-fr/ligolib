#import "../../contracts/cameligo/betting/main.mligo" "Betting"
#import "../../contracts/cameligo/betting/types.mligo" "Types"
#import "helpers/bootstrap.mligo" "Bootstrap"
#import "helpers/helper.mligo" "Helper"
#import "helpers/assert.mligo" "Assert"
#import "helpers/events.mligo" "Events"
#import "helpers/log.mligo" "Log"

let () = Log.describe("[AddBet] test suite")

let test_bet_team_one_should_work =
    let (_, betting_contract, betting_taddress, elon, _, alice, _, _) = Bootstrap.bootstrap() in
    let () = Assert.assert_events_map betting_taddress Helper.empty_map in
    let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
    let () = Assert.assert_events_map betting_taddress Helper.one_event_map in

    let bet_one_map : (nat, Types.event_bets) big_map = Big_map.literal [
    (0n, {
        bets_team_one = (Map.literal [ (alice, 2000000mutez) ]);
        bets_team_one_index = 1n ;
        bets_team_one_total = 2000000mutez ;
        bets_team_two = (Map.empty : (address, tez) map );
        bets_team_two_index = 0n ;
        bets_team_two_total = 0mutez ;
        }
        )
    ] in

    let () = Helper.trsc_add_bet_success (betting_contract, alice, 0n, (true : bool), 2000000mutez) in
    let () = Assert.assert_events_bet_map betting_taddress bet_one_map in
    "OK"

let test_bet_team_both_should_work =
    let (_, betting_contract, betting_taddress, elon, _, alice, _, _) = Bootstrap.bootstrap() in
    let () = Assert.assert_events_map betting_taddress Helper.empty_map in
    let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
    let () = Assert.assert_events_map betting_taddress Helper.one_event_map in

    let bet_both_map : (nat, Types.event_bets) big_map = Big_map.literal [
    (0n, {
        bets_team_one = (Map.literal [ (alice, 2000000mutez) ]);
        bets_team_one_index = 1n ;
        bets_team_one_total = 2000000mutez ;
        bets_team_two = (Map.literal [ (alice, 4000000mutez) ]);
        bets_team_two_index = 1n ;
        bets_team_two_total = 4000000mutez ;
        }
        )
    ] in

    let () = Helper.trsc_add_bet_success (betting_contract, alice, 0n, (true : bool), 2000000mutez) in
    let () = Helper.trsc_add_bet_success (betting_contract, alice, 0n, (false : bool), 4000000mutez) in
    let () = Assert.assert_events_bet_map betting_taddress bet_both_map in
    "OK"

let test_bet_various_entries_should_work =
    let (_, betting_contract, betting_taddress, elon, _, alice, bob, mike) = Bootstrap.bootstrap() in
    let () = Assert.assert_events_map betting_taddress Helper.empty_map in
    let () = Helper.trsc_add_event_success (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event)) in
    let () = Assert.assert_events_map betting_taddress Helper.one_event_map in

    let bet_last_map : (nat, Types.event_bets) big_map = Big_map.literal [
    (0n, {
        bets_team_one = (Map.literal [ (alice, (20000000mutez)); (bob, 1000000mutez); ]);
        bets_team_one_index = (1n + 1n) ;
        bets_team_one_total = (20000000mutez + 1000000mutez) ;
        bets_team_two = (Map.literal [ (alice, (10000000mutez)); (mike, 3000000mutez); (bob, 7000000mutez) ]);
        bets_team_two_index = (1n + 1n + 1n) ;
        bets_team_two_total = (10000000mutez + 3000000mutez + 7000000mutez) ;
        }
        )
    ] in

    let () = Helper.trsc_add_bet_success (betting_contract, alice, 0n, (true : bool), (20000000mutez)) in
    let () = Helper.trsc_add_bet_success (betting_contract, bob, 0n, (true : bool), 1000000mutez) in
    let () = Helper.trsc_add_bet_success (betting_contract, alice, 0n, (false : bool), 10000000mutez) in
    let () = Helper.trsc_add_bet_success (betting_contract, mike, 0n, (false : bool), 3000000mutez) in
    let () = Helper.trsc_add_bet_success (betting_contract, bob, 0n, (false : bool), 7000000mutez) in
    let () = Assert.assert_events_bet_map betting_taddress bet_last_map in
    "OK"