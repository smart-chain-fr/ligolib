#import "../types.mligo" "BETTING_TYPES"

type storage = 
  [@layout:comb] {
  name : string;
  videogame : string;
  begin_at : timestamp;
  end_at : timestamp;
  modified_at : timestamp;
  opponents : { teamOne : string; teamTwo : string};
  isFinalized : bool;
  isDraw : bool option;
  isTeamOneWin : bool option;
  startBetTime : timestamp;
  closedBetTime : timestamp;
  betsTeamOne : (address, tez) map;
  betsTeamOne_index : nat;
  betsTeamOne_total : tez;
  betsTeamTwo : (address, tez) map;
  betsTeamTwo_index : nat;
  betsTeamTwo_total : tez;
  metadata : (string, bytes) map;
  bettingAddr : address;
  }

type requested_event_param = [@layout:comb] {
  name : string;
  videogame : string;
  begin_at : timestamp;
  end_at : timestamp;
  modified_at : timestamp;
  opponents : { teamOne : string; teamTwo : string};
  isFinalized : bool;
  isDraw : bool option;
  isTeamOneWin : bool option;
  startBetTime : timestamp;
  closedBetTime : timestamp;
  betsTeamOne : (address, tez) map;
  betsTeamOne_index : nat;
  betsTeamOne_total : tez;
  betsTeamTwo : (address, tez) map;
  betsTeamTwo_index : nat;
  betsTeamTwo_total : tez;
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
    isFinalized=param.isFinalized;
    isDraw=param.isDraw;
    isTeamOneWin=param.isTeamOneWin;
    startBetTime=param.startBetTime;
    closedBetTime=param.closedBetTime;
    betsTeamOne=param.betsTeamOne;
    betsTeamOne_index=param.betsTeamOne_index;
    betsTeamOne_total=param.betsTeamOne_total;
    betsTeamTwo=param.betsTeamTwo;
    betsTeamTwo_index=param.betsTeamTwo_index;
    betsTeamTwo_total=param.betsTeamTwo_total;
  })

let requestEvent(param, store : nat * storage) : operation list * storage =
  let payload : BETTING_TYPES.get_event_parameter = {
    requestedEventID=param;
    callback=Tezos.get_self_address();
  } in
  let destination : BETTING_TYPES.get_event_parameter contract = 
    match (Tezos.get_entrypoint_opt "%getEvent" store.bettingAddr : BETTING_TYPES.get_event_parameter contract option) with
    | None -> failwith("Unknown entrypoint GetEvent")
    | Some ctr -> ctr
  in
  let op : operation = Tezos.transaction payload 0mutez destination in
  ([op], store)

let main ((param, s):(parameter * storage)) : operation list * storage =
  match param with
  | SaveEvent p -> saveEvent(p, s)
  | RequestEvent p -> requestEvent(p, s)

