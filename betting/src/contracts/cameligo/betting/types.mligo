type eventType = 
  [@layout:comb] {
  name : string;
  videogame : string;
  begin_at : timestamp;
  end_at : timestamp;
  modified_at : timestamp;
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

type betConfigType = {
  isBettingPaused : bool;
  isEventCreationPaused : bool;
  minBetAmount : nat;
  minPeriodToBet : nat;
  maxBetDifference : nat;
  retainedProfitFee : nat;
}

type storage = {
  manager : address;
  oracleAddress : address;
  retainedProfits : tez;
  betConfig : betConfigType;
  events : (nat, eventType) map;
  events_index : nat;
  metadata : (string, bytes) map;
}

type updateEventParameter =
  [@layout:comb] {
  updatedEventID : nat;
  updatedEvent : eventType;
}

type callbackAskedParameter =
  [@layout:comb] {
  requestedEventID : nat;
  callback : address
}

type callbackReturnedValue =
  [@layout:comb] {
  requestedEvent : eventType;
  callback : address
}

type action =
  ChangeManager of address
  | ChangeOracleAddress of address
  | SwitchPause of unit
  | AddEvent of eventType
  | GetEvent of callbackAskedParameter
  | UpdateEvent of updateEventParameter