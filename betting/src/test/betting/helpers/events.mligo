#import "../../../contracts/cameligo/betting/types.mligo" "TYPES"

let plainTimestamp : timestamp = ("1970-01-01T00:00:01Z" : timestamp)

let eventype_to_addeventparam (evttype : TYPES.event_type) : TYPES.add_event_parameter =
  let addEvtParam : TYPES.add_event_parameter = {
    name=evttype.name;
    videogame=evttype.videogame;
    begin_at=evttype.begin_at;
    end_at=evttype.end_at;
    modified_at=evttype.modified_at;
    opponents=evttype.opponents;
    isFinalized=evttype.isFinalized;
    isDraw=evttype.isDraw;
    isTeamOneWin=evttype.isTeamOneWin;
    startBetTime=evttype.startBetTime;
    closedBetTime=evttype.closedBetTime;
  } in
  addEvtParam

let primaryEvent : TYPES.event_type = {
  name          = "First Event";
  videogame     = "Videogame ONE";
  begin_at      = plainTimestamp + 3074;
  end_at        = plainTimestamp + 4096;
  modified_at   = plainTimestamp;
  opponents     = { teamOne = "Team ONE"; teamTwo = "Team TWO"};
  isFinalized   = false;
  isDraw        = (None : bool option);
  isTeamOneWin  = (None : bool option);
  startBetTime  = plainTimestamp;
  closedBetTime = plainTimestamp + 3072;
  is_claimed    = False;
  }

let secondaryEvent : TYPES.event_type = {
  name          = "Secondary Event";
  videogame     = "Videogame TWO";
  begin_at      = plainTimestamp + 3074;
  end_at        = plainTimestamp + 4096;
  modified_at   = plainTimestamp;
  opponents     = { teamOne = "Team THREE"; teamTwo = "Team FOUR"};
  isFinalized   = false;
  isDraw        = (None : bool option);
  isTeamOneWin  = (None : bool option);
  startBetTime  = plainTimestamp;
  closedBetTime = plainTimestamp + 3072;
  is_claimed    = False;
}

let finalized_event_team1_win : TYPES.event_type = {
  name          = "First Event";
  videogame     = "Videogame ONE";
  begin_at      = plainTimestamp + 3;
  end_at        = plainTimestamp + 4;
  modified_at   = plainTimestamp;
  opponents     = { teamOne = "Team ONE"; teamTwo = "Team TWO"};
  isFinalized   = (true : bool);
  isDraw        = (Some(false) : bool option);
  isTeamOneWin  = (Some(true)  : bool option);
  startBetTime  = plainTimestamp + 1;
  closedBetTime = plainTimestamp + 2;
  is_claimed    = False;
}

let finalized_event_team2_win : TYPES.event_type = {
  name          = "First Event";
  videogame     = "Videogame ONE";
  begin_at      = plainTimestamp + 3;
  end_at        = plainTimestamp + 4;
  modified_at   = plainTimestamp;
  opponents     = { teamOne = "Team ONE"; teamTwo = "Team TWO"};
  isFinalized   = (true : bool);
  isDraw        = (Some(false) : bool option);
  isTeamOneWin  = (Some(false) : bool option);
  startBetTime  = plainTimestamp + 1;
  closedBetTime = plainTimestamp + 2;
  is_claimed    = False;
}

let finalized_event_draw : TYPES.event_type = {
  name          = "First Event";
  videogame     = "Videogame ONE";
  begin_at      = plainTimestamp + 3;
  end_at        = plainTimestamp + 4;
  modified_at   = plainTimestamp;
  opponents     = { teamOne = "Team ONE"; teamTwo = "Team TWO"};
  isFinalized   = (true : bool);
  isDraw        = (Some(true) : bool option);
  isTeamOneWin  = (None : bool option);
  startBetTime  = plainTimestamp + 1;
  closedBetTime = plainTimestamp + 2;
  is_claimed    = False;
}