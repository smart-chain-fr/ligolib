type bet_config_type = {
  // is betting on events paused (true), or is it allowed (false)
  isBettingPaused : bool;
  // is creating new events paused (true), or is it allowed (false)
  isEventCreationPaused : bool;
  // what is the minimum amount to bet on an event in one transaction
  minBetAmount : tez;
  // what is the quota to be retained from bet profits (deduced as operating gains to the contract, shown as percentage, theorical max is 100)
  retainedProfitQuota : nat;
}

type event_type = 
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
  is_claimed : bool;
}

type event_bets =
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
  betConfig : bet_config_type;
  events : (nat, event_type) map;
  events_bets : (nat, event_bets) map;
  events_index : nat;
  metadata : (string, bytes) map;
}

type get_event_parameter =
  [@layout:comb] {
  requestedEventID : nat;
  callback : address;
}

type update_event_parameter =
  [@layout:comb] {
  updatedEventID : nat;
  updatedEvent : event_type;
}

type add_bet_parameter =
  [@layout:comb] {
  requestedEventID : nat;
  teamOneBet : bool
}

type finalize_bet_parameter = nat

type callback_event_parameter = 
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

type callback_asked_parameter =
  [@layout:comb] {
  requestedEventID : nat;
  callback : address
}

type callback_returned_value =
  [@layout:comb] {
  requestedEvent : callback_event_parameter;
  callback : address
}


type add_event_parameter = 
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


type action =
  | ChangeManager of address
  | ChangeOracleAddress of address
  | SwitchPauseBetting
  | SwitchPauseEventCreation
  | UpdateConfigType of bet_config_type
  | AddEvent of add_event_parameter
  | GetEvent of get_event_parameter
  | UpdateEvent of update_event_parameter
  | AddBet of add_bet_parameter
  | FinalizeBet of finalize_bet_parameter