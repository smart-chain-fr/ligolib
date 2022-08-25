#import "../../contracts/cameligo/betting/main.mligo" "BETTING"
#import "../../contracts/cameligo/betting/types.mligo" "TYPES"
#import "helpers/bootstrap.mligo" "BOOTSTRAP"
#import "helpers/helper.mligo" "HELPER"
#import "helpers/assert.mligo" "ASSERT"

let () = Test.log("___ TEST finalizeBet STARTED ___")
let plainTimestamp : timestamp = ("1970-01-01T00:00:01Z" : timestamp)

let (betting_contract, betting_taddress, elon, jeff, alice, bob, mike) = BOOTSTRAP.bootstrap

let () = Test.log("-> Initial Storage :")
let () = Test.log(betting_contract, betting_taddress, elon, jeff)
let () =  HELPER.trscAddEvent (betting_contract, elon, BOOTSTRAP.primaryEvent)
let () = ASSERT.assert_eventsMap betting_taddress HELPER.oneEventMap

let aliceBetLastMap : (nat, TYPES.eventBets) map = Map.literal [
    (0n, {
        betsTeamOne = (Map.literal [ (alice, (22000000mutez)); (bob, 1000000mutez); ]);
        betsTeamOne_index = (1n + 1n) ;
        betsTeamOne_total = (22000000mutez + 1000000mutez) ;
        betsTeamTwo = (Map.literal [ (alice, (24000000mutez)); (mike, 3000000mutez); (bob, 7000000mutez) ]);
        betsTeamTwo_index = (1n + 1n + 1n) ;
        betsTeamTwo_total = (24000000mutez + 3000000mutez + 7000000mutez) ;
        }
    )
    ]

let () = HELPER.trscAddBet (betting_contract, alice, 0n, (true : bool), 22000000mutez)
let () = HELPER.trscAddBet (betting_contract, bob, 0n, (true : bool), 1000000mutez)
let () = HELPER.trscAddBet (betting_contract, alice, 0n, (false : bool), 24000000mutez)
let () = HELPER.trscAddBet (betting_contract, mike, 0n, (false : bool), 3000000mutez)
let () = HELPER.trscAddBet (betting_contract, bob, 0n, (false : bool), 7000000mutez)
let () = ASSERT.assert_eventsBetMap betting_taddress aliceBetLastMap


let finalizedEvent : TYPES.eventType = {
    name = "First Event";
    videogame= "Videogame ONE";
    begin_at= plainTimestamp + 3;
    end_at= plainTimestamp + 4;
    modified_at= plainTimestamp;
    opponents = { teamOne = "Team ONE"; teamTwo = "Team TWO"};
    isFinalized = (true : bool);
    isDraw = (None : bool option);
    isTeamOneWin = (None : bool option);
    startBetTime = plainTimestamp + 1;
    closedBetTime = plainTimestamp + 2;
    }

let oneEventFinalizedMap : (nat, TYPES.eventType) map = Map.literal [ (0n, finalizedEvent) ]

let () = HELPER.trscUpdateEvent (betting_contract, elon, 0n, finalizedEvent)

let () = Test.log("___ Balances Before Rewards ___")
let () = Test.log("Alice",Test.get_balance(alice))
let () = Test.log("Bob",Test.get_balance(bob))
let () = Test.log("Mike",Test.get_balance(mike))

let () = HELPER.trscFinalizeBet (betting_contract, elon, 0n)
let () = ASSERT.assert_eventsMap betting_taddress oneEventFinalizedMap

let () = Test.log("___ Balances After Rewards ___")
let () = Test.log("Alice",Test.get_balance(alice))
let () = Test.log("Bob",Test.get_balance(bob))
let () = Test.log("Mike",Test.get_balance(mike))


let () = Test.log("___ TEST finalizeBet ENDED ___")