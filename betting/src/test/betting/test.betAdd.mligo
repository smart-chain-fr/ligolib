#import "../../contracts/cameligo/betting/main.mligo" "Betting"
#import "../../contracts/cameligo/betting/types.mligo" "Types"
#import "helpers/bootstrap.mligo" "Bootstrap"
#import "helpers/helper.mligo" "Helper"
#import "helpers/assert.mligo" "Assert"
#import "helpers/events.mligo" "Events"
#import "helpers/log.mligo" "Log"

let () = Log.describe("[AddBet] test suite")

let () = Test.log("-> Timing Now :")
let () = Test.log( Tezos.get_now() )

let (_betting_address, betting_contract, betting_taddress, elon, jeff, alice, bob, mike) = Bootstrap.bootstrap()

let () = Assert.assert_eventsMap betting_taddress Helper.empty_map
let () = Helper.trsc_add_event (betting_contract, elon, Events.eventype_to_addeventparam(Events.primary_event))
let () = Assert.assert_eventsMap betting_taddress Helper.one_event_map

let aliceBetOneMap : (nat, Types.event_bets) big_map = Big_map.literal [
    (0n, {
        bets_team_one = (Map.literal [ (alice, 2000000mutez) ]);
        bets_team_one_index = 1n ;
        bets_team_one_total = 2000000mutez ;
        bets_team_two = (Map.empty : (address, tez) map );
        bets_team_two_index = 0n ;
        bets_team_two_total = 0mutez ;
        }
        )
    ]

let () = Test.log("-> Adding a Bet to TeamOne for an existing event")
let () = Helper.trscAddBet (betting_contract, alice, 0n, (true : bool), 2000000mutez)
let () = Assert.assert_eventsBetMap betting_taddress aliceBetOneMap

let aliceBetBothMap : (nat, Types.event_bets) big_map = Big_map.literal [
    (0n, {
        bets_team_one = (Map.literal [ (alice, 2000000mutez) ]);
        bets_team_one_index = 1n ;
        bets_team_one_total = 2000000mutez ;
        bets_team_two = (Map.literal [ (alice, 4000000mutez) ]);
        bets_team_two_index = 1n ;
        bets_team_two_total = 4000000mutez ;
        }
        )
    ]

let () = Test.log("-> Adding a Bet to TeamTwo for an existing event")
let () = Helper.trscAddBet (betting_contract, alice, 0n, (false : bool), 4000000mutez)
let () = Assert.assert_eventsBetMap betting_taddress aliceBetBothMap

let aliceBetLastMap : (nat, Types.event_bets) big_map = Big_map.literal [
    (0n, {
        bets_team_one = (Map.literal [ (alice, (2000000mutez + 20000000mutez)); (bob, 1000000mutez); ]);
        bets_team_one_index = (1n + 1n) ;
        bets_team_one_total = (2000000mutez + 20000000mutez + 1000000mutez) ;
        bets_team_two = (Map.literal [ (alice, (4000000mutez + 20000000mutez)); (mike, 3000000mutez); (bob, 7000000mutez) ]);
        bets_team_two_index = (1n + 1n + 1n) ;
        bets_team_two_total = (4000000mutez + 20000000mutez + 3000000mutez + 7000000mutez) ;
        }
        )
    ]

let () = Test.log("-> Adding a Bet to both teams for an existing event")
let () = Helper.trscAddBet (betting_contract, alice, 0n, (true : bool), 20000000mutez)
let () = Helper.trscAddBet (betting_contract, bob, 0n, (true : bool), 1000000mutez)
let () = Helper.trscAddBet (betting_contract, alice, 0n, (false : bool), 20000000mutez)
let () = Helper.trscAddBet (betting_contract, mike, 0n, (false : bool), 3000000mutez)
let () = Helper.trscAddBet (betting_contract, bob, 0n, (false : bool), 7000000mutez)
let () = Assert.assert_eventsBetMap betting_taddress aliceBetLastMap