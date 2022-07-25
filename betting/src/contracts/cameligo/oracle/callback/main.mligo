type storage = 
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
  }

type action = nat

let main ((p, _):(storage * storage)) =
  (([]: operation list), p)