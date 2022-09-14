#import "../types.mligo" "BETTING_TYPES"

type storage = 
  [@layout:comb] {
  name : string;
  videogame : string;
  begin_at : timestamp;
  end_at : timestamp;
  modified_at : timestamp;
  opponents : { team_one : string; team_two : string};
  is_finalized : bool;
  is_draw : bool option;
  is_team_one_win : bool option;
  start_bet_time : timestamp;
  closed_bet_time : timestamp;
  bets_team_one : (address, tez) map;
  bets_team_one_index : nat;
  bets_team_one_total : tez;
  bets_team_two : (address, tez) map;
  bets_team_two_index : nat;
  bets_team_two_total : tez;
  metadata : (string, bytes) map;
  bettingAddr : address;
  }

type requested_event_param = [@layout:comb] {
  name : string;
  videogame : string;
  begin_at : timestamp;
  end_at : timestamp;
  modified_at : timestamp;
  opponents : { team_one : string; team_two : string};
  is_finalized : bool;
  is_draw : bool option;
  is_team_one_win : bool option;
  start_bet_time : timestamp;
  closed_bet_time : timestamp;
  bets_team_one : (address, tez) map;
  bets_team_one_index : nat;
  bets_team_one_total : tez;
  bets_team_two : (address, tez) map;
  bets_team_two_index : nat;
  bets_team_two_total : tez;
}

type parameter = SaveEvent of requested_event_param | RequestEvent of nat


let saveEvent(param, store : requested_event_param * storage) : operation list * storage =
  (([]: operation list), { store with 
    name=param.name;
    videogame=param.videogame;
    begin_at=param.begin_at;
    end_at=param.end_at;
    modified_at=param.modified_at;
    opponents=param.opponents;
    is_finalized=param.is_finalized;
    is_draw=param.is_draw;
    is_team_one_win=param.is_team_one_win;
    start_bet_time=param.start_bet_time;
    closed_bet_time=param.closed_bet_time;
    bets_team_one=param.bets_team_one;
    bets_team_one_index=param.bets_team_one_index;
    bets_team_one_total=param.bets_team_one_total;
    bets_team_two=param.bets_team_two;
    bets_team_two_index=param.bets_team_two_index;
    bets_team_two_total=param.bets_team_two_total;
  })

let requestEvent(param, store : nat * storage) : operation list * storage =
  let payload : BETTING_TYPES.callback_asked_parameter = {
    requested_event_id=param;
    callback=Tezos.get_self_address();
  } in
  let destination : BETTING_TYPES.callback_asked_parameter contract = 
    match (Tezos.get_entrypoint_opt "%getEvent" store.bettingAddr : BETTING_TYPES.callback_asked_parameter contract option) with
    | None -> failwith("Unknown entrypoint GetEvent")
    | Some ctr -> ctr
  in
  let op : operation = Tezos.transaction payload 0mutez destination in
  ([op], store)

let main ((param, s):(parameter * storage)) : operation list * storage =
  match param with
  | SaveEvent p -> saveEvent(p, s)
  | RequestEvent p -> requestEvent(p, s)

