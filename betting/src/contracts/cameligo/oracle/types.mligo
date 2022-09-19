type event_type = 
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

type storage =
  [@layout:comb] {
  isPaused : bool;
  manager : address;
  signer : address;
  events : (nat, event_type) map;
  events_index : nat;
  metadata : (string, bytes) map;
}

type update_event_parameter =
  [@layout:comb] {
  updated_event_id : nat;
  updated_event : event_type;
}

type callback_asked_parameter =
  [@layout:comb] {
  requested_event_id : nat;
  callback : address
}

type callback_returned_value =
  [@layout:comb] {
  requestedEvent : event_type;
  callback : address
}

type action =
  | ChangeManager of address
  | ChangeSigner of address
  | SwitchPause
  | AddEvent of event_type
  | GetEvent of callback_asked_parameter
  | UpdateEvent of update_event_parameter