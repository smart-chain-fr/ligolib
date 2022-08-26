type betConfigType = {
  // is betting on events paused (true), or is it allowed (false)
  isBettingPaused : bool;
  // is creating new events paused (true), or is it allowed (false)
  isEventCreationPaused : bool;
  // what is the minimum amount to bet on an event in one transaction
  minBetAmount : tez;
  // what is the quota to be retained from bet profits (deduced as operating gains to the contract, shown as percentage, theorical max is 100)
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
  isDraw : bool option;
  isTeamOneWin : bool option;
  startBetTime : timestamp;
  closedBetTime : timestamp;
}

type eventBets =
  [@layout:comb] {
  betsTeamOne : (address, tez) map;
  betsTeamOne_index : nat;
  betsTeamOne_total : tez;
  betsTeamTwo : (address, tez) map;
  betsTeamTwo_index : nat;
  betsTeamTwo_total : tez;
  }

type storage = {
  manager : address;
  oracleAddress : address;
  betConfig : betConfigType;
  events : (nat, eventType) map;
  events_bets : (nat, eventBets) map;
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

type callbackEventParameter = 
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
  }

type callbackAskedParameter =
  [@layout:comb] {
  requestedEventID : nat;
  callback : address
}

type callbackReturnedValue =
  [@layout:comb] {
  requestedEvent : callbackEventParameter;
  callback : address
}

type action =
  | ChangeManager of address
  | ChangeOracleAddress of address
  | SwitchPauseBetting
  | SwitchPauseEventCreation
  | UpdateConfigType of betConfigType
  | AddEvent of eventType
  | GetEvent of getEventParameter
  | UpdateEvent of updateEventParameter
  | AddBet of addBetParameter
  | FinalizeBet of finalizeBetParameter