# Betting Contract

This contract represents a Tezos contract written in CameLIGO in which users can bet on events added by the Admin or an Oracle.

The current implementation of the contract is as follows :

## Structure :
- a `Betting` contract, the main contract
- _(optional)_ a `callback` contract for the `Betting`
- _(optional)_ a `mock Oracle` contract
- _(optional)_ a `callback` contract for the `mock Oracle`

## Storage :
```ocaml
type storage = {
  manager : address;
  oracle_address : address;
  bet_config : bet_config_type;
  events : (nat, event_type) map;
  events_bets : (nat, event_bets) map;
  events_index : nat;
  metadata : (string, bytes) map;
}
```
- `manager` : Manager **account** of the Betting contract
- `oracle_address` : Oracle **contract** allowed to add Events and update them
- `events`, `events_bets`, `events_index` : Events mapped to their info, their attached bets, and the latest index
```ocaml
type bet_config_type = {
  is_betting_paused : bool;
  is_event_creation_paused : bool;
  min_bet_amount : tez;
  retained_profit_quota : nat;
}
```
- `is_betting_paused` : is Betting on Events paused (true), or is it allowed (false)
- `is_event_creation_paused` : is the creation of new Events paused (true), or is it allowed (false)
- `min_bet_amount` : the minimum amount to Bet on an Event in a single transaction
- `retainedProfit` : the quota to be retained from Betting profits (deduced as operating gains to the contract, shown as percentage, theorical max is 100)

## Process :
1) Deploy the Betting contract with an initial storage
2) The `storage.bet_config.is_betting_paused` and `storage.bet_config.is_event_creation_paused` must have as value `false`
3) Add an Event using the `storage.manager` address
4) Add a Bet to the Event using an address that is not `storage.manager` nor `storage.oracle_address`
5) _(optional)_ Add more bets to the first team or second team on the Event
6) Update the Bet to specify the outcome in `is_draw`, and the winning Team in `is_team_one_win` if it is not a draw, using `storage.manager` or `storage.oracle_address`
7) Finalize the Bet using `storage.manager`

## Initial Storage example :
```ocaml
let initBetConfig : bet_config_type = {
      is_betting_paused = false;
      is_event_creation_paused = false;
      min_bet_amount = 5tez;
      retained_profit_quota = 10n;
} in

let init_storage : storage = {
      manager = "tz1******************";
      oracle_address = "KT1******************";
      bet_config = initBetConfig;
      events = (Map.empty : (nat, event_type) map);
      events_bets = (Map.empty : (nat, event_bets) map);
      events_index = 0n;
      metadata = (Map.empty : (string, bytes) map);
} in
```

### - Compile Betting contract :
- To compile the Betting contract to Michelson code :
```bash
docker run --platform linux/amd64 --rm -v "$(PWD)":"$(PWD)" -w "$(PWD)" ligolang/ligo:0.49.0 compile contract src/contracts/cameligo/betting/main.mligo > src/compiled/betting.tz
```
- To compile the Betting contract to Michelson code in JSON format :
```bash
docker run --platform linux/amd64 --rm -v "$(PWD)":"$(PWD)" -w "$(PWD)" ligolang/ligo:0.49.0 compile contract src/contracts/cameligo/betting/main.mligo --michelson-format json > src/compiled/betting.json
```

### - Compile Betting storage :
- Using `tz1bdTsc3QdAj1935KiMxou6frwdm5RDdssT` as example for `storage.manager`
- Using `KT1KMjSSDxTAUZAb7rgGYx3JF4Yz1cwQpwUi` as example for `storage.oracle_address`
```bash
docker run --platform linux/amd64 --rm -v "$(PWD)":"$(PWD)" -w "$(PWD)" ligolang/ligo:0.49.0 compile storage ./contracts/cameligo/betting/main.mligo '{manager = ("tz1bdTsc3QdAj1935KiMxou6frwdm5RDdssT" : address); oracle_address = ("KT1KMjSSDxTAUZAb7rgGYx3JF4Yz1cwQpwUi" : address); bet_config = {is_betting_paused = false; is_event_creation_paused = false; min_bet_amount = 5tez; retained_profit_quota = 10n}; events = (Map.empty : (nat, TYPES.event_type) map); events_bets = (Map.empty : (nat, TYPES.event_bets) map); events_index = 0n; metadata = (Map.empty : (string, bytes) map)}' -e main
```

### - Simulate execution of entrypoints (with ligo compiler) :

- For entrypoint SendValue
```bash
docker run --platform linux/amd64 --rm -v "$(PWD)":"$(PWD)" -w "$(PWD)" ligolang/ligo:0.49.0 run dry-run src/contracts/cameligo/betting/main.mligo 'SendValue(unit)' '37' -e indiceMain
```

### - Originate the Indice contract (with tezos-client CLI)
- Compile the storage into Michelson expression :
- Using `tz1bdTsc3QdAj1935KiMxou6frwdm5RDdssT` as example for `storage.manager`
- Using `KT1KMjSSDxTAUZAb7rgGYx3JF4Yz1cwQpwUi` as example for `storage.oracle_address`
```bash
docker run --platform linux/amd64 --rm -v "$(PWD)":"$(PWD)" -w "$(PWD)" ligolang/ligo:0.49.0 compile storage ./contracts/cameligo/betting/main.mligo '{manager = ("tz1bdTsc3QdAj1935KiMxou6frwdm5RDdssT" : address); oracle_address = ("KT1KMjSSDxTAUZAb7rgGYx3JF4Yz1cwQpwUi" : address); bet_config = {is_betting_paused = false; is_event_creation_paused = false; min_bet_amount = 5tez; retained_profit_quota = 10n}; events = (Map.empty : (nat, TYPES.event_type) map); events_bets = (Map.empty : (nat, TYPES.event_bets) map); events_index = 0n; metadata = (Map.empty : (string, bytes) map)}' -e main
```
- This command produces the following Michelson storage :
```ocaml
(Pair (Pair (Pair (Pair (Pair False False) 5000000 10) {}) {} 0)
      (Pair "tz1bdTsc3QdAj1935KiMxou6frwdm5RDdssT" {})
      "KT1KMjSSDxTAUZAb7rgGYx3JF4Yz1cwQpwUi")
```
- Deploy with tezos-client CLI using the above Michelson code :
```bash
tezos-client originate contract betting transferring 1 from '$USER_ADDRESS' running 'src/compiled/betting.tz' --init '(Pair (Pair (Pair (Pair (Pair False False) 5000000 10) {}) {} 0)(Pair "tz1bdTsc3QdAj1935KiMxou6frwdm5RDdssT" {})"KT1KMjSSDxTAUZAb7rgGYx3JF4Yz1cwQpwUi")'
```