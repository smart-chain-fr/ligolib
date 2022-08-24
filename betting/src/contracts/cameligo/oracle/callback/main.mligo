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
  metadata : (string, bytes) map;
  }

type action = nat

let main ((p, _):(storage * storage)) =
  (([]: operation list), p)