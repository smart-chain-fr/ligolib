type eventType = 
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

type storage =
  [@layout:comb] {
  isPaused : bool;
  manager : address;
  signer : address;
  events : (nat, eventType) map;
  events_index : nat;
}

type updateEventParameter =
  [@layout:comb] {
  updatedEventID : nat;
  updatedEvent : eventType;
}

type callbackAskedParameter =
  [@layout:comb] {
  requestedEventID : nat;
  callback : address
}

type callbackReturnedValue =
  [@layout:comb] {
  requestedEvent : eventType;
  callback : address
}

type action =
  ChangeManager of address
  | ChangeSigner of address
  | SwitchPause of unit
  | AddEvent of eventType
  | GetEvent of callbackAskedParameter
  | UpdateEvent of updateEventParameter