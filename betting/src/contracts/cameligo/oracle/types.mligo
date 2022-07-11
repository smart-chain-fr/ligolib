type oracleEventType = 
  [@layout:comb] {
  name : string;
  videogame: string;
  begin_at: timestamp;
  end_at: timestamp;
  modified_at: timestamp;
  opponents : { teamOne : string; teamTwo : string};
  isFinished : bool;
  isDraw : bool option;
  isTeamOneWin : bool option;
  startBetTime : timestamp;
  closedBetTime : timestamp;
  betsTeamOne : (address, tez) map;
  betsTeamOne_index : nat;
  betsTeamTwo : (address, tez) map;
  betsTeamTwo_index : nat;
  closedTeamOneRate : nat option
}

type storage =
  [@layout:comb] {
  isPaused : bool;
  manager : address;
  signer : address;
  events : (nat, oracleEventType) map;
  events_index : nat;
}

type callbackReturnedValue =
  [@layout:comb] {
  requestedEvent : nat;
  callback : address
}

type parameter = string * callbackReturnedValue contract

type action =
  ChangeManager of address
  | ChangeSigner of address
  | SwitchPause of unit
  | AddEvent of oracleEventType
  | GetEvent of nat
  | UpdateEvent of nat