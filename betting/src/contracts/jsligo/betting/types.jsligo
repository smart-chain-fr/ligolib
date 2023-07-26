type bet_config_type = {
  // is betting on events paused (true), or is it allowed (false)
  is_betting_paused : bool;
  // is creating new events paused (true), or is it allowed (false)
  is_event_creation_paused : bool;
  // what is the minimum amount to bet on an event in one transaction
  min_bet_amount : tez;
  // what is the quota to be retained from bet profits (deduced as operating gains to the contract, shown as percentage, theorical max is 100)
  retained_profit_quota : nat;
}

type game_status = Ongoing | Team1Win| Team2Win | Draw

type event_type = 
  [@layout:comb] {
  name : string;
  videogame : string;
  begin_at : timestamp;
  end_at : timestamp;
  modified_at : timestamp;
  opponents : { team_one : string; team_two : string};
  game_status : game_status;
  start_bet_time : timestamp;
  closed_bet_time : timestamp;
  is_claimed : bool;
}

type event_bets =
  [@layout:comb] {
  bets_team_one : (address, tez) map;
  bets_team_one_index : nat;
  bets_team_one_total : tez;
  bets_team_two : (address, tez) map;
  bets_team_two_index : nat;
  bets_team_two_total : tez;
  }

type event_key = nat

type storage = {
  manager : address;
  oracle_address : address;
  bet_config : bet_config_type;
  events : (event_key, event_type) big_map;
  events_bets : (event_key, event_bets) big_map;
  events_index : event_key;
  metadata : (string, bytes) map;
}

type callback_asked_parameter =
  [@layout:comb] {
  requested_event_id : nat;
  callback : address;
}

type update_event_parameter =
  [@layout:comb] {
  updated_event_id : nat;
  updated_event : event_type;
}

type add_bet_parameter =
  [@layout:comb] {
  requested_event_id : nat;
  team_one_bet : bool
}

type finalize_bet_parameter = nat

type add_event_parameter = 
[@layout:comb] {
  name : string;
  videogame : string;
  begin_at : timestamp;
  end_at : timestamp;
  modified_at : timestamp;
  opponents : { team_one : string; team_two : string};
  game_status : game_status;
  start_bet_time : timestamp;
  closed_bet_time : timestamp;
}


type action =
  | ChangeManager of address
  | ChangeOracleAddress of address
  | SwitchPauseBetting
  | SwitchPauseEventCreation
  | UpdateConfigType of bet_config_type
  | AddEvent of add_event_parameter
  | GetEvent of callback_asked_parameter
  | UpdateEvent of update_event_parameter
  | AddBet of add_bet_parameter
  | FinalizeBet of finalize_bet_parameter