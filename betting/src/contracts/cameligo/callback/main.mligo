type storage = 
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

type action = nat

let main ((p, _):(storage * storage)) =
  (([]: operation list), p)