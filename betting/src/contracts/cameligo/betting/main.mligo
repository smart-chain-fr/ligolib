// Betting & Predictive Market - CameLIGO contract

#import "types.mligo" "TYPES"
#import "errors.mligo" "ERRORS"
#import "assert.mligo" "ASSERT"

// --------------------------------------
//      CONFIGURATION INTERACTIONS
// --------------------------------------

let change_manager (p_new_manager : address)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assert_is_manager (Tezos.get_sender()) s.manager in
  let _ = ASSERT.assert_not_previous_manager p_new_manager s.manager in
  (([] : operation list), {s with manager = p_new_manager})

let change_oracle_address (p_new_oracle_address : address)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assert_is_manager (Tezos.get_sender()) s.manager in
  let _ = ASSERT.assert_not_previous_oracle p_new_oracle_address s.oracleAddress in
  (([] : operation list), {s with oracleAddress = p_new_oracle_address})

let switch_pause_event_creation (s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assert_is_manager (Tezos.get_sender()) s.manager in
  if (s.betConfig.isEventCreationPaused)
    then (([] : operation list), {s with betConfig.isEventCreationPaused = false})
    else (([] : operation list), {s with betConfig.isEventCreationPaused = true})

let switch_pause_betting (s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assert_is_manager (Tezos.get_sender()) s.manager in
  if (s.betConfig.isBettingPaused)
    then (([] : operation list), {s with betConfig.isBettingPaused = false})
    else (([] : operation list), {s with betConfig.isBettingPaused = true})

let update_config_type (p_new_bet_config : TYPES.betConfigType)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assert_is_manager (Tezos.get_sender()) s.manager in
  (([] : operation list), {s with betConfig = p_new_bet_config})


// --------------------------------------
//          EVENT INTERACTIONS
// --------------------------------------

let add_event (p_new_event : TYPES.eventType)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assert_is_manager_or_oracle (Tezos.get_sender()) s.manager s.oracleAddress in
  let _ = ASSERT.assert_event_creation_not_paused s.betConfig.isEventCreationPaused in
  let _ = ASSERT.assert_event_start_to_end_date p_new_event.begin_at p_new_event.end_at in
  let _ = ASSERT.assert_event_bet_start_to_end_date p_new_event.startBetTime p_new_event.closedBetTime in
  let _ = ASSERT.assert_event_bet_start_after_end p_new_event.startBetTime p_new_event.end_at in
  let _ = ASSERT.assert_event_bet_ends_after_end p_new_event.closedBetTime p_new_event.end_at in
  let new_events : (nat, TYPES.eventType) map = (Map.add (s.events_index) p_new_event s.events) in
  let new_event_bet : TYPES.eventBets = {
    betsTeamOne = (Map.empty : (address, tez) map);
    betsTeamOne_index = 0n;
    betsTeamOne_total = 0mutez;
    betsTeamTwo = (Map.empty : (address, tez) map);
    betsTeamTwo_index = 0n;
    betsTeamTwo_total = 0mutez;
  } in
  let new_events_bets : (nat, TYPES.eventBets) map = (Map.add (s.events_index) new_event_bet s.events_bets) in
  (([] : operation list), {s with events = new_events; events_bets = new_events_bets; events_index = (s.events_index + 1n)})

let get_event (requested_event_id : nat)(callback : address)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let cbk_event = match Map.find_opt requested_event_id s.events with
    | Some event -> event
    | None -> (failwith ERRORS.no_event_id)
    in
  let cbk_eventbet = match Map.find_opt requested_event_id s.events_bets with
    | Some eventbet -> eventbet
    | None -> (failwith ERRORS.no_event_id)
    in
  let returned_value : TYPES.callbackReturnedValue = {
    requestedEvent = {
      name = cbk_event.name;
      videogame = cbk_event.videogame;
      begin_at = cbk_event.begin_at;
      end_at = cbk_event.end_at;
      modified_at = cbk_event.modified_at;
      opponents = { teamOne = cbk_event.opponents.teamOne; teamTwo = cbk_event.opponents.teamTwo};
      isFinalized = cbk_event.isFinalized;
      isDraw = cbk_event.isDraw;
      isTeamOneWin = cbk_event.isTeamOneWin;
      startBetTime = cbk_event.startBetTime;
      closedBetTime = cbk_event.closedBetTime;
      betsTeamOne = cbk_eventbet.betsTeamOne;
      betsTeamOne_index = cbk_eventbet.betsTeamOne_index;
      betsTeamOne_total = cbk_eventbet.betsTeamOne_total;
      betsTeamTwo = cbk_eventbet.betsTeamTwo;
      betsTeamTwo_index = cbk_eventbet.betsTeamTwo_index;
      betsTeamTwo_total = cbk_eventbet.betsTeamTwo_total;
    };
    callback = callback;
  } in
  let _ = Tezos.transaction(returned_value, 0mutez, callback) in
  (([] : operation list), s)

let update_event (updated_event_id : nat)(updatedEvent : TYPES.eventType)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assert_is_manager_or_oracle (Tezos.get_sender()) s.manager s.oracleAddress in
  let _ = ASSERT.assert_event_start_to_end_date updatedEvent.begin_at updatedEvent.end_at in
  let _ = ASSERT.assert_event_bet_start_to_end_date updatedEvent.startBetTime updatedEvent.closedBetTime in
  let _ = ASSERT.assert_event_bet_start_after_end updatedEvent.startBetTime updatedEvent.end_at in
  let _ = ASSERT.assert_event_bet_ends_after_end updatedEvent.closedBetTime updatedEvent.end_at in
  let _ = match Map.find_opt updated_event_id s.events with
    | Some event -> event
    | None -> (failwith ERRORS.no_event_id)
  in
  let new_events : (nat, TYPES.eventType) map = Map.update updated_event_id (Some(updatedEvent)) s.events in
  (([] : operation list), {s with events = new_events})

// --------------------------------------
//         BETTING INTERACTIONS
// --------------------------------------

let add_bet_team_one_amount_to_existing_user (p_requested_event_id : TYPES.eventBets)(pPreviousAmount : tez) =
  let p_new_bets_team_one : (address, tez) map = Map.update (Tezos.get_sender()) (Some(pPreviousAmount + Tezos.get_amount())) p_requested_event_id.betsTeamOne in
  (p_new_bets_team_one, p_requested_event_id.betsTeamOne_index)

let add_bet_team_one_amount_to_new_user (p_requested_event_id : TYPES.eventBets) =
  let p_new_bets_team_one : (address, tez) map = Map.add (Tezos.get_sender()) (Tezos.get_amount()) p_requested_event_id.betsTeamOne in
  let p_new_bets_team_one_index : nat = (p_requested_event_id.betsTeamOne_index + 1n) in
  (p_new_bets_team_one, p_new_bets_team_one_index)

let add_bet_team_one (p_requested_event_id : TYPES.eventBets) : TYPES.eventBets =
  let (new_bets_team_one, new_bets_team_one_index) : ((address, tez) map * nat) = match (Map.find_opt (Tezos.get_sender()) p_requested_event_id.betsTeamOne) with
    | Some prevAmount -> add_bet_team_one_amount_to_existing_user p_requested_event_id prevAmount
    | None -> add_bet_team_one_amount_to_new_user p_requested_event_id
  in
  let new_bets_team_one_total : tez = (p_requested_event_id.betsTeamOne_total + Tezos.get_amount()) in
  let r_updatedEvent : TYPES.eventBets = {p_requested_event_id with betsTeamOne = new_bets_team_one; betsTeamOne_index = new_bets_team_one_index; betsTeamOne_total = new_bets_team_one_total;} in
  (r_updatedEvent)


let add_bet_team_two_amount_to_existing_user (p_requested_event_id : TYPES.eventBets)(pPreviousAmount : tez) =
  let p_newbetsTeamTwo : (address, tez) map = Map.update (Tezos.get_sender()) (Some(pPreviousAmount + Tezos.get_amount())) p_requested_event_id.betsTeamTwo in
  (p_newbetsTeamTwo, p_requested_event_id.betsTeamTwo_index)

let add_bet_team_twoAmountToNewUser (p_requested_event_id : TYPES.eventBets) =
  let p_newbetsTeamTwo : (address, tez) map = Map.add (Tezos.get_sender()) (Tezos.get_amount()) p_requested_event_id.betsTeamTwo in
  let p_newbetsTeamTwo_index : nat = (p_requested_event_id.betsTeamTwo_index + 1n) in
  (p_newbetsTeamTwo, p_newbetsTeamTwo_index)

let add_bet_team_two (p_requested_event_id : TYPES.eventBets) : TYPES.eventBets =
  let (newbetsTeamTwo, newbetsTeamTwo_index) : ((address, tez) map * nat) = match (Map.find_opt (Tezos.get_sender()) p_requested_event_id.betsTeamTwo) with
    | Some prevAmount -> add_bet_team_two_amount_to_existing_user p_requested_event_id prevAmount
    | None -> add_bet_team_twoAmountToNewUser p_requested_event_id
  in
  let newbetsTeamTwo_total : tez = (p_requested_event_id.betsTeamTwo_total + Tezos.get_amount()) in
  let r_updatedEvent : TYPES.eventBets = {p_requested_event_id with betsTeamTwo = newbetsTeamTwo; betsTeamTwo_index = newbetsTeamTwo_index; betsTeamTwo_total = newbetsTeamTwo_total;} in
  (r_updatedEvent)

let add_bet (p_requested_event_id : nat)(teamOneBet : bool)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assert_not_manager_nor_oracle (Tezos.get_sender()) s.manager s.oracleAddress in
  let _ = ASSERT.assert_no_tez (Tezos.get_amount()) in
  let _ = ASSERT.assert_tez_lower_than_min (Tezos.get_amount()) s.betConfig.minBetAmount in
  let requested_event : TYPES.eventType = match (Map.find_opt p_requested_event_id s.events) with
    | Some event -> event
    | None -> failwith ERRORS.no_event_id
  in
  let _ = ASSERT.assert_betting_not_finalized (requested_event.isFinalized) in
  let _ = ASSERT.assert_betting_before_period_start (requested_event.begin_at) in
  let _ = ASSERT.assert_betting_after_period_end (requested_event.end_at) in
  let requested_event_bets : TYPES.eventBets = match (Map.find_opt p_requested_event_id s.events_bets) with
    | Some event -> event
    | None -> failwith ERRORS.no_event_bets
  in
  let updated_bet_event : TYPES.eventBets = if (teamOneBet)
    then ( let uEvent : TYPES.eventBets = add_bet_team_one requested_event_bets in (uEvent) )
    else ( let uEvent : TYPES.eventBets = add_bet_team_two requested_event_bets in (uEvent) )
  in
  let new_events_map : (nat, TYPES.eventBets) map = (Map.update p_requested_event_id (Some(updated_bet_event)) s.events_bets) in
  (([] : operation list), {s with events_bets = new_events_map;})

let trs_reward_bet_winners (p_requested_event_bets : TYPES.eventBets)(pWinner : address)(pBetAmount : tez)(s : TYPES.storage) : unit =
  let initialAmount : tez = match (pBetAmount - ((pBetAmount * s.betConfig.retainedProfitQuota) / 100n)) with
    | Some tezAmount -> tezAmount
    | None -> failwith ERRORS.bet_reward_incorrect
  in
  let opponentAmount : tez = (p_requested_event_bets.betsTeamOne_total / p_requested_event_bets.betsTeamOne_index) in
  let finalAmount : tez = (initialAmount + opponentAmount) in
  let _ = Tezos.transaction((), finalAmount, pWinner) in
  ()

let reward_bet_winners (p_requested_event_bets : TYPES.eventBets)(pWinnersMap : (address, tez) map)(s : TYPES.storage) : unit =
  let calculate = fun (iWinner, jBetAmount : address * tez) -> trs_reward_bet_winners p_requested_event_bets iWinner jBetAmount s in
  let _ = Map.iter calculate pWinnersMap in
  ()

let trs_reward_bet_draw (pWinner : address)(pBetAmount : tez)(s : TYPES.storage) : unit =
  let _ = Tezos.transaction((), (pBetAmount - ((pBetAmount * s.betConfig.retainedProfitQuota) / 100n)), pWinner) in
  ()

let refund_bet_players (pTeamOneMap : (address, tez) map)(pTeamTwoMap : (address, tez) map)(s : TYPES.storage) : unit =
  let calculate = fun (dPlayer, dBetAmount : address * tez) -> trs_reward_bet_draw dPlayer dBetAmount s in
  let _ = Map.iter calculate pTeamOneMap in
  let _ = Map.iter calculate pTeamTwoMap in
  ()

let finalize_bet (p_requested_event_id : nat)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assert_is_manager (Tezos.get_sender()) s.manager in
  let requested_event : TYPES.eventType = match (Map.find_opt p_requested_event_id s.events) with
    | Some event -> event
    | None -> failwith ERRORS.no_event_id
  in
  let requested_event_bets : TYPES.eventBets = match (Map.find_opt p_requested_event_id s.events_bets) with
    | Some event -> event
    | None -> failwith ERRORS.no_event_bets
  in
  let _ = ASSERT.assert_betting_not_finalized (requested_event.isFinalized) in
  let _ = ASSERT.assert_finalizing_before_period_end (requested_event.end_at) in
  let updatedEvent : TYPES.eventType = {requested_event with isFinalized = true} in
  let outcomeDraw : bool = match requested_event.isDraw with
    | Some x -> x
    | None -> failwith ERRORS.bet_no_team_outcome
  in
  let _ = if (outcomeDraw)
    then (refund_bet_players requested_event_bets.betsTeamOne requested_event_bets.betsTeamTwo s)
    else (
      let outcomeTeamOneWin : bool = match requested_event.isTeamOneWin with
        | Some x -> x
        | None -> failwith ERRORS.bet_no_team_outcome
      in
      if (outcomeTeamOneWin)
        then ( reward_bet_winners requested_event_bets requested_event_bets.betsTeamOne s )
        else ( reward_bet_winners requested_event_bets requested_event_bets.betsTeamTwo s )
    )
  in
  let new_events_map : (nat, TYPES.eventType) map = (Map.update p_requested_event_id (Some(updatedEvent)) s.events) in
  (([] : operation list), {s with events = new_events_map;})

// --------------------------------------
//            MAIN FUNCTION
// --------------------------------------

let main (params, s : TYPES.action * TYPES.storage) : (operation list * TYPES.storage) =
  let result = match params with
    | ChangeManager m -> change_manager m s
    | ChangeOracleAddress o -> change_oracle_address o s
    | SwitchPauseBetting -> switch_pause_betting s
    | SwitchPauseEventCreation -> switch_pause_event_creation s
    | UpdateConfigType c -> update_config_type c s
    | AddEvent e -> add_event e s
    | GetEvent p -> get_event p.requestedEventID p.callback s
    | UpdateEvent p -> update_event p.updatedEventID p.updatedEvent s
    | AddBet b -> add_bet b.requestedEventID b.teamOneBet s
    | FinalizeBet b -> finalize_bet b s
  in
  result

// --------------------------------------
//            CONTRACT VIEWS
// --------------------------------------

[@view]
let getManager (_, s : unit * TYPES.storage) : timestamp * address =
  (Tezos.get_now(), s.manager)

[@view]
let getOracleAddress (_, s : unit * TYPES.storage) : timestamp * address =
  (Tezos.get_now(), s.oracleAddress)

[@view]
let getBettingStatus (_, s : unit * TYPES.storage) : timestamp * bool =
  (Tezos.get_now(), s.betConfig.isBettingPaused)

[@view]
let getEventCreationStatus (_, s : unit * TYPES.storage) : timestamp * bool =
  (Tezos.get_now(), s.betConfig.isEventCreationPaused)

[@view]
let getEvent (p_requested_event_id, s : nat * TYPES.storage) : timestamp * TYPES.eventType =
  let requested_event : TYPES.eventType = match (Map.find_opt p_requested_event_id s.events) with
    | Some event -> event
    | None -> failwith ERRORS.no_event_id
  in
  (Tezos.get_now(), requested_event)