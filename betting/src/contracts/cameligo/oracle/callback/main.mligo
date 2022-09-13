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

type requested_event_param = 
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
  }

type parameter = SaveEvent of requested_event_param | Nothing of unit

let saveEvent(param, store : requested_event_param * storage) : operation list * storage =
  (([]: operation list), { store with 
    name=param.name;
    videogame=param.videogame;
    begin_at=param.begin_at;
    end_at=param.end_at;
    modified_at=param.modified_at;
    opponents=param.opponents;
    isFinalized=param.isFinalized;
    isDraw=param.isDraw;
    isTeamOneWin=param.isTeamOneWin;
  })

let main ((p, s):(parameter * storage)) : operation list * storage =
  match p with
  | SaveEvent p -> saveEvent(p, s)
  | Nothing _p -> (([]: operation list), s)