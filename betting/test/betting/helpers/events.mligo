#import "../../../src/contracts/cameligo/betting/types.mligo" "Types"

let plain_timestamp : timestamp = ("1970-01-01T00:00:01Z" : timestamp)

let eventype_to_addeventparam (evttype : Types.event_type) : Types.add_event_parameter =
  let addEvtParam : Types.add_event_parameter = {
    name            = evttype.name;
    videogame       = evttype.videogame;
    begin_at        = evttype.begin_at;
    end_at          = evttype.end_at;
    modified_at     = evttype.modified_at;
    opponents       = evttype.opponents;
    game_status     = evttype.game_status;
    start_bet_time  = evttype.start_bet_time;
    closed_bet_time = evttype.closed_bet_time;
  } in
  addEvtParam

let primary_event : Types.event_type = {
  name             = "First Event";
  videogame        = "Videogame ONE";
  begin_at         = plain_timestamp + 3074;
  end_at           = plain_timestamp + 4096;
  modified_at      = plain_timestamp;
  opponents        = { team_one = "Team ONE"; team_two = "Team TWO"};
  game_status      = Ongoing;
  start_bet_time   = plain_timestamp;
  closed_bet_time  = plain_timestamp + 3072;
  is_claimed       = False;
  }

let secondary_event : Types.event_type = {
  name             = "Secondary Event";
  videogame        = "Videogame TWO";
  begin_at         = plain_timestamp + 3074;
  end_at           = plain_timestamp + 4096;
  modified_at      = plain_timestamp;
  opponents        = { team_one = "Team THREE"; team_two = "Team FOUR"};
  game_status      = Ongoing;
  start_bet_time   = plain_timestamp;
  closed_bet_time  = plain_timestamp + 3072;
  is_claimed       = False;
}

let finalized_event_team1_win : Types.event_type = {
  name             = "First Event";
  videogame        = "Videogame ONE";
  begin_at         = plain_timestamp + 3;
  end_at           = plain_timestamp + 4;
  modified_at      = plain_timestamp;
  opponents        = { team_one = "Team ONE"; team_two = "Team TWO"};
  game_status      = Team1Win;
  start_bet_time   = plain_timestamp + 1;
  closed_bet_time  = plain_timestamp + 2;
  is_claimed       = False;
}

let finalized_event_team2_win : Types.event_type = {
  name            = "First Event";
  videogame       = "Videogame ONE";
  begin_at        = plain_timestamp + 3;
  end_at          = plain_timestamp + 4;
  modified_at     = plain_timestamp;
  opponents       = { team_one = "Team ONE"; team_two = "Team TWO"};
  game_status     = Team2Win;
  start_bet_time  = plain_timestamp + 1;
  closed_bet_time = plain_timestamp + 2;
  is_claimed      = False;
}

let finalized_event_draw : Types.event_type = {
  name             = "First Event";
  videogame        = "Videogame ONE";
  begin_at         = plain_timestamp + 3;
  end_at           = plain_timestamp + 4;
  modified_at      = plain_timestamp;
  opponents        = { team_one = "Team ONE"; team_two = "Team TWO"};
  game_status      = Draw;
  start_bet_time   = plain_timestamp + 1;
  closed_bet_time  = plain_timestamp + 2;
  is_claimed       = False;
}

let finalized_event_too_long : Types.event_type = {
  name            = "First Event";
  videogame       = "Videogame ONE";
  begin_at        = plain_timestamp + 3;
  end_at          = plain_timestamp + 400000;
  modified_at     = plain_timestamp;
  opponents       = { team_one = "Team ONE"; team_two = "Team TWO"};
  game_status     = Draw;
  start_bet_time  = plain_timestamp + 1;
  closed_bet_time = plain_timestamp + 2;
  is_claimed      = False;
}