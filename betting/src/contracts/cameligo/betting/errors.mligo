// --------------------------------------
//         CONFIG RELATED ERRORS
// --------------------------------------

let not_manager : string = "Not the Manager of the contract"
let not_manager_or_oracle : string = "Not the Manager or Oracle of the contract"
let same_previous_manager : string = "New Manager address can't be the same as the current one"
let same_previous_oracleAddress : string = "New Oracle address can't be the same as the current one"

// --------------------------------------
//         EVENT RELATED ERRORS
// --------------------------------------

let no_event_id : string = "No Event with this ID"
let event_creation_paused : string = "Event Creation is currently paused"

// --------------------------------------
//         BETTING RELATED ERRORS
// --------------------------------------

let bet_creation_paused : string = "Betting is currently paused"
let bet_manager_or_oracle : string = "The Manager and Oracle of the contract can not bet"
let no_bet_on_address : string = "No Bet with this Address"
let bet_with_no_tez : string = "No Tez sent for betting"
let bet_lower_than_minimum : string = "Your bet cannot be lower than the minimum"
let bet_before_event_start : string = "You can not bet before the start of the Betting period"
let bet_after_event_end : string = "You can not bet after the end of the Betting period"
let bet_finished : string = "Bet is marked as finalized"
let bet_not_finished : string = "Bet is marked as finalized"
let bet_window_finished : string = "Betting period is marked as finalized"
let bet_no_event_outcome : string = "Bet does not have an outcome on which team won"