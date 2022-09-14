type storage = 
  [@layout:comb] {
  name : string;
  videogame : string;
  begin_at : timestamp;
  end_at : timestamp;
  modified_at : timestamp;
  opponents : { team_one : string; team_two : string};
  is_finalized : bool;
  is_draw : bool option;
  is_team_one_win : bool option;
  metadata : (string, bytes) map;
  }

type requested_event_param = 
  [@layout:comb] {
    name : string;
    videogame : string;
    begin_at : timestamp;
    end_at : timestamp;
    modified_at : timestamp;
    opponents : { team_one : string; team_two : string};
    is_finalized : bool;
    is_draw : bool option;
    is_team_one_win : bool option;
  }

type parameter = SaveEvent of requested_event_param | Nothing of unit

let saveEvent(param, store : requested_event_param * storage) : operation list * storage =
  (([]: operation list), { store with 
    name = param.name;
    videogame = param.videogame;
    begin_at = param.begin_at;
    end_at = param.end_at;
    modified_at = param.modified_at;
    opponents = param.opponents;
    is_finalized = param.is_finalized;
    is_draw = param.is_draw;
    is_team_one_win = param.is_team_one_win;
  })

let main ((p, s):(parameter * storage)) : operation list * storage =
  match p with
  | SaveEvent p -> saveEvent(p, s)
  | Nothing _p -> (([]: operation list), s)