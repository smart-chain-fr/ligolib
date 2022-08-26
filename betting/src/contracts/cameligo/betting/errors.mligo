// --------------------------------------
//         CONFIG RELATED ERRORS
// --------------------------------------

let not_manager : string = "Not the Manager of the contract"
let not_manager_nor_oracle : string = "Not the Manager or Oracle of the contract"
let same_previous_manager : string = "New Manager address can't be the same as the current one"
let same_previous_oracleAddress : string = "New Oracle address can't be the same as the current one"

// --------------------------------------
//         EVENT RELATED ERRORS
// --------------------------------------

let no_event_id : string = "No Event with this ID"
let no_event_bets : string = "No Event Bets with this ID"
let event_creation_paused : string = "Event Creation is currently paused"

let event_end_before_start : string = "Event End Date can't be before Start Date"
let event_betting_end_before_start : string = "Event Betting End Date can't be before Betting Start Date"

let event_betting_start_after_end : string = "Event Betting Start Date can't be after the Event Start Date"
let event_betting_end_after_end : string = "Event Betting End Date can't be after the Event End Date"

// --------------------------------------
//         BETTING RELATED ERRORS
// --------------------------------------

let betting_paused : string = "Betting is currently paused"
let bet_as_manager_or_oracle : string = "The Manager and Oracle of the contract can not bet"
let no_bet_on_address : string = "No Bet exists with this Address"

let bet_with_no_tez : string = "No Tez sent for betting"
let bet_lower_than_minimum : string = "Your bet cannot be lower than the minimum"

let bet_before_event_start : string = "You can not bet before the start of the Betting period"
let bet_after_event_end : string = "You can not bet after the end of the Betting period"

let bet_finished : string = "Bet is marked as finalized"
let bet_not_finished : string = "Bet is not marked as finalized"

let bet_period_not_started : string = "Betting period has not started yet"
let bet_period_not_finished : string = "Betting period has not ended yet"
let bet_period_finished : string = "Betting period has ended"

let bet_no_team_outcome : string = "Bet does not have an outcome yet on which team won"
let bet_ended_as_draw : string = "Bet ended in a Draw"

let bet_reward_incorrect : string = "Bet reward calculations went wrong"