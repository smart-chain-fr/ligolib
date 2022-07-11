type eventType =
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
  betsTeamTwo : (address, tez) map;
  closedTeamOneRate : nat option
}

type betConfigType = {
  isEventCreationPaused : bool;
  minBetAmount : nat;
  minPeriodToBet : nat;
  maxBetDifference : nat;
  retainedProfitFee : nat;
}

type storage = {
  isBettingPaused : bool;
  manager : address;
  oracleAddress : address;
  retainedProfits : tez;
  betConfig : betConfigType;
  events : (nat, eventType) map;
  metadata : (string, bytes) map;
}