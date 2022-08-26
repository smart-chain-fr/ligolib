type event_type = 
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
  updatedEventID : nat;
  updatedEvent : event_type;
}

type callback_asked_parameter =
  [@layout:comb] {
  requestedEventID : nat;
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