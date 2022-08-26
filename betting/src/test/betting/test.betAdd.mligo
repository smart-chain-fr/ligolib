#import "../../contracts/cameligo/betting/main.mligo" "BETTING"
#import "../../contracts/cameligo/betting/types.mligo" "TYPES"
#import "helpers/bootstrap.mligo" "BOOTSTRAP"
#import "helpers/helper.mligo" "HELPER"
#import "helpers/assert.mligo" "ASSERT"

let () = Test.log("___ TEST AddBet STARTED ___")

let () = Test.log("-> Timing Now :")
let () = Test.log( Tezos.get_now() )

let (betting_contract, betting_taddress, elon, jeff, alice, bob, mike) = BOOTSTRAP.bootstrap

let () = Test.log("-> Initial Storage :")
let () = Test.log(betting_contract, betting_taddress, elon, jeff)
let () = ASSERT.assert_eventsMap betting_taddress HELPER.emptyMap
let () = HELPER.trscAddEvent (betting_contract, elon, BOOTSTRAP.primaryEvent)
let () = ASSERT.assert_eventsMap betting_taddress HELPER.oneEventMap

let aliceBetOneMap : (nat, TYPES.event_bets) map = Map.literal [
    (0n, {
        betsTeamOne = (Map.literal [ (alice, 2000000mutez) ]);
        betsTeamOne_index = 1n ;
        betsTeamOne_total = 2000000mutez ;
        betsTeamTwo = (Map.empty : (address, tez) map );
        betsTeamTwo_index = 0n ;
        betsTeamTwo_total = 0mutez ;
        }
        )
    ]

let () = Test.log("-> Adding a Bet to TeamOne for an existing event")
let () = HELPER.trscAddBet (betting_contract, alice, 0n, (true : bool), 2000000mutez)
let () = ASSERT.assert_eventsBetMap betting_taddress aliceBetOneMap

let aliceBetBothMap : (nat, TYPES.event_bets) map = Map.literal [
    (0n, {
        betsTeamOne = (Map.literal [ (alice, 2000000mutez) ]);
        betsTeamOne_index = 1n ;
        betsTeamOne_total = 2000000mutez ;
        betsTeamTwo = (Map.literal [ (alice, 4000000mutez) ]);
        betsTeamTwo_index = 1n ;
        betsTeamTwo_total = 4000000mutez ;
        }
        )
    ]

let () = Test.log("-> Adding a Bet to TeamTwo for an existing event")
let () = HELPER.trscAddBet (betting_contract, alice, 0n, (false : bool), 4000000mutez)
let () = ASSERT.assert_eventsBetMap betting_taddress aliceBetBothMap

let aliceBetLastMap : (nat, TYPES.event_bets) map = Map.literal [
    (0n, {
        betsTeamOne = (Map.literal [ (alice, (2000000mutez + 20000000mutez)); (bob, 1000000mutez); ]);
        betsTeamOne_index = (1n + 1n) ;
        betsTeamOne_total = (2000000mutez + 20000000mutez + 1000000mutez) ;
        betsTeamTwo = (Map.literal [ (alice, (4000000mutez + 20000000mutez)); (mike, 3000000mutez); (bob, 7000000mutez) ]);
        betsTeamTwo_index = (1n + 1n + 1n) ;
        betsTeamTwo_total = (4000000mutez + 20000000mutez + 3000000mutez + 7000000mutez) ;
        }
        )
    ]

let () = Test.log("-> Adding a Bet to both teams for an existing event")
let () = HELPER.trscAddBet (betting_contract, alice, 0n, (true : bool), 20000000mutez)
let () = HELPER.trscAddBet (betting_contract, bob, 0n, (true : bool), 1000000mutez)
let () = HELPER.trscAddBet (betting_contract, alice, 0n, (false : bool), 20000000mutez)
let () = HELPER.trscAddBet (betting_contract, mike, 0n, (false : bool), 3000000mutez)
let () = HELPER.trscAddBet (betting_contract, bob, 0n, (false : bool), 7000000mutez)
let () = ASSERT.assert_eventsBetMap betting_taddress aliceBetLastMap


let () = Test.log("___ TEST AddBet ENDED ___")