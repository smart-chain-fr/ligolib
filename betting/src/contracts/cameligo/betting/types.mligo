type betConfigType = {
  isBettingPaused : bool;
  isEventCreationPaused : bool;
  minBetAmount : tez;
  minPeriodToBet : nat;
  maxBetDifference : nat;
  retainedProfitQuota : nat;
}

type eventType = 
  [@layout:comb] {
  name : string;
  videogame : string;
  begin_at : timestamp;
  end_at : timestamp;
  modified_at : timestamp;
  opponents : { teamOne : string; teamTwo : string};
  isFinalized : bool;
  isFinished : bool;
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
  closedTeamOneRate : nat option;
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

type getEventParameter =
  [@layout:comb] {
  requestedEventID : nat;
  callback : address;
}

type updateEventParameter =
  [@layout:comb] {
  updatedEventID : nat;
  updatedEvent : eventType;
}

type addBetParameter =
  [@layout:comb] {
  requestedEventID : nat;
  teamOneBet : bool
}

type finalizeBetParameter = nat

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
  | SwitchPauseBetting
  | SwitchPauseEventCreation
  | AddEvent of eventType
  | GetEvent of getEventParameter
  | UpdateEvent of updateEventParameter
  | AddBet of addBetParameter
  | FinalizeBet of finalizeBetParameter