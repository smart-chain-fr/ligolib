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
    is_finalized=evttype.is_finalized;
    is_draw=evttype.is_draw;
    is_team_one_win=evttype.is_team_one_win;
    start_bet_time=evttype.start_bet_time;
    closed_bet_time=evttype.closed_bet_time;
  } in
  addEvtParam

let primaryEvent : TYPES.event_type = {
  name          = "First Event";
  videogame     = "Videogame ONE";
  begin_at      = plainTimestamp + 3074;
  end_at        = plainTimestamp + 4096;
  modified_at   = plainTimestamp;
  opponents     = { team_one = "Team ONE"; team_two = "Team TWO"};
  is_finalized   = false;
  is_draw        = (None : bool option);
  is_team_one_win  = (None : bool option);
  start_bet_time  = plainTimestamp;
  closed_bet_time = plainTimestamp + 3072;
  is_claimed    = False;
  }

let secondaryEvent : TYPES.event_type = {
  name          = "Secondary Event";
  videogame     = "Videogame TWO";
  begin_at      = plainTimestamp + 3074;
  end_at        = plainTimestamp + 4096;
  modified_at   = plainTimestamp;
  opponents     = { team_one = "Team THREE"; team_two = "Team FOUR"};
  is_finalized   = false;
  is_draw        = (None : bool option);
  is_team_one_win  = (None : bool option);
  start_bet_time  = plainTimestamp;
  closed_bet_time = plainTimestamp + 3072;
  is_claimed    = False;
}

let finalized_event_team1_win : TYPES.event_type = {
  name          = "First Event";
  videogame     = "Videogame ONE";
  begin_at      = plainTimestamp + 3;
  end_at        = plainTimestamp + 4;
  modified_at   = plainTimestamp;
  opponents     = { team_one = "Team ONE"; team_two = "Team TWO"};
  is_finalized   = (true : bool);
  is_draw        = (Some(false) : bool option);
  is_team_one_win  = (Some(true)  : bool option);
  start_bet_time  = plainTimestamp + 1;
  closed_bet_time = plainTimestamp + 2;
  is_claimed    = False;
}

let finalized_event_team2_win : TYPES.event_type = {
  name          = "First Event";
  videogame     = "Videogame ONE";
  begin_at      = plainTimestamp + 3;
  end_at        = plainTimestamp + 4;
  modified_at   = plainTimestamp;
  opponents     = { team_one = "Team ONE"; team_two = "Team TWO"};
  is_finalized   = (true : bool);
  is_draw        = (Some(false) : bool option);
  is_team_one_win  = (Some(false) : bool option);
  start_bet_time  = plainTimestamp + 1;
  closed_bet_time = plainTimestamp + 2;
  is_claimed    = False;
}

let finalized_event_draw : TYPES.event_type = {
  name          = "First Event";
  videogame     = "Videogame ONE";
  begin_at      = plainTimestamp + 3;
  end_at        = plainTimestamp + 4;
  modified_at   = plainTimestamp;
  opponents     = { team_one = "Team ONE"; team_two = "Team TWO"};
  is_finalized   = (true : bool);
  is_draw        = (Some(true) : bool option);
  is_team_one_win  = (None : bool option);
  start_bet_time  = plainTimestamp + 1;
  closed_bet_time = plainTimestamp + 2;
  is_claimed    = False;
}