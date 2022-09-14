// Betting & Predictive Market - CameLIGO contract

#import "types.mligo" "TYPES"
#import "errors.mligo" "ERRORS"
#import "assert.mligo" "ASSERT"
#import "callback/main.mligo" "CALLBACK"

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

let update_config_type (p_new_bet_config : TYPES.bet_config_type)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assert_is_manager (Tezos.get_sender()) s.manager in
  (([] : operation list), {s with betConfig = p_new_bet_config})

// --------------------------------------
//          EVENT INTERACTIONS
// --------------------------------------

let add_event (p_new_event : TYPES.add_event_parameter)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assert_is_manager_or_oracle (Tezos.get_sender()) s.manager s.oracleAddress in
  let _ = ASSERT.assert_event_creation_not_paused s.betConfig.isEventCreationPaused in
  let _ = ASSERT.assert_event_start_to_end_date p_new_event.begin_at p_new_event.end_at in
  let _ = ASSERT.assert_event_bet_start_to_end_date p_new_event.startBetTime p_new_event.closedBetTime in
  let _ = ASSERT.assert_event_bet_start_after_end p_new_event.startBetTime p_new_event.end_at in
  let _ = ASSERT.assert_event_bet_ends_after_end p_new_event.closedBetTime p_new_event.end_at in
  let new_event : TYPES.event_type = { 
    name = p_new_event.name;
    videogame =  p_new_event.videogame;
    begin_at = p_new_event.begin_at;
    end_at = p_new_event.end_at;
    modified_at = p_new_event.modified_at;
    opponents = p_new_event.opponents;
    isFinalized = p_new_event.isFinalized;
    isDraw = p_new_event.isDraw;
    isTeamOneWin = p_new_event.isTeamOneWin;
    startBetTime = p_new_event.startBetTime;
    closedBetTime = p_new_event.closedBetTime;
    is_claimed = False } in
  let new_events : (nat, TYPES.event_type) big_map = (Big_map.add (s.events_index) new_event s.events) in
  let new_event_bet : TYPES.event_bets = {
    betsTeamOne = (Map.empty : (address, tez) map);
    betsTeamOne_index = 0n;
    betsTeamOne_total = 0mutez;
    betsTeamTwo = (Map.empty : (address, tez) map);
    betsTeamTwo_index = 0n;
    betsTeamTwo_total = 0mutez;
  } in
  let new_events_bets : (nat, TYPES.event_bets) big_map = (Big_map.add (s.events_index) new_event_bet s.events_bets) in
  (([] : operation list), {s with events = new_events; events_bets = new_events_bets; events_index = (s.events_index + 1n)})

let get_event (requested_event_id : nat)(callbackAddr : address)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let cbk_event =
    match Big_map.find_opt requested_event_id s.events with
      Some event -> event
    | None -> (failwith ERRORS.no_event_id)
    in
  let cbk_eventbet = match Big_map.find_opt requested_event_id s.events_bets with
    | Some eventbet -> eventbet
    | None -> (failwith ERRORS.no_event_id)
    in
  let returned_value : CALLBACK.requested_event_param = {
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
    } in
  let destination : CALLBACK.requested_event_param contract = 
  match (Tezos.get_entrypoint_opt "%saveEvent" callbackAddr : CALLBACK.requested_event_param contract option) with
  | None -> failwith("Unknown contract")
  | Some ctr -> ctr
  in
  let op : operation = Tezos.transaction returned_value 0mutez destination in
  ([op], s)


let update_event (updated_event_id : nat)(updatedEvent : TYPES.event_type)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assert_is_manager_or_oracle (Tezos.get_sender()) s.manager s.oracleAddress in
  let _ = ASSERT.assert_event_start_to_end_date updatedEvent.begin_at updatedEvent.end_at in
  let _ = ASSERT.assert_event_bet_start_to_end_date updatedEvent.startBetTime updatedEvent.closedBetTime in
  let _ = ASSERT.assert_event_bet_start_after_end updatedEvent.startBetTime updatedEvent.end_at in
  let _ = ASSERT.assert_event_bet_ends_after_end updatedEvent.closedBetTime updatedEvent.end_at in
  let requested_event = match Big_map.find_opt updated_event_id s.events with
    | Some event -> event
    | None -> (failwith ERRORS.no_event_id)
  in
  let _ = ASSERT.assert_betting_not_finalized (requested_event.isFinalized) in
  let new_events : (nat, TYPES.event_type) big_map = Big_map.update updated_event_id (Some(updatedEvent)) s.events in
  (([] : operation list), {s with events = new_events})

// --------------------------------------
//         BETTING INTERACTIONS
// --------------------------------------

let add_bet_team_one_amount_to_existing_user (p_requested_event_id : TYPES.event_bets)(pPreviousAmount : tez) =
  let p_new_bets_team_one : (address, tez) map = Map.update (Tezos.get_sender()) (Some(pPreviousAmount + Tezos.get_amount())) p_requested_event_id.betsTeamOne in
  (p_new_bets_team_one, p_requested_event_id.betsTeamOne_index)


let add_bet_team_one_amount_to_new_user (p_requested_event_id : TYPES.event_bets) =
  let p_new_bets_team_one : (address, tez) map = Map.add (Tezos.get_sender()) (Tezos.get_amount()) p_requested_event_id.betsTeamOne in
  let p_new_bets_team_one_index : nat = (p_requested_event_id.betsTeamOne_index + 1n) in
  (p_new_bets_team_one, p_new_bets_team_one_index)


let add_bet_team_one (p_requested_event_id : TYPES.event_bets) : TYPES.event_bets =
  let (new_bets_team_one, new_bets_team_one_index) : ((address, tez) map * nat) = match (Map.find_opt (Tezos.get_sender()) p_requested_event_id.betsTeamOne) with
    | Some prevAmount -> add_bet_team_one_amount_to_existing_user p_requested_event_id prevAmount
    | None -> add_bet_team_one_amount_to_new_user p_requested_event_id
  in
  let new_bets_team_one_total : tez = (p_requested_event_id.betsTeamOne_total + Tezos.get_amount()) in
  let r_updatedEvent : TYPES.event_bets = {p_requested_event_id with betsTeamOne = new_bets_team_one; betsTeamOne_index = new_bets_team_one_index; betsTeamOne_total = new_bets_team_one_total;} in
  (r_updatedEvent)


let add_bet_team_two_amount_to_existing_user (p_requested_event_id : TYPES.event_bets)(pPreviousAmount : tez) =
  let p_newbetsTeamTwo : (address, tez) map = Map.update (Tezos.get_sender()) (Some(pPreviousAmount + Tezos.get_amount())) p_requested_event_id.betsTeamTwo in
  (p_newbetsTeamTwo, p_requested_event_id.betsTeamTwo_index)


let add_bet_team_twoAmountToNewUser (p_requested_event_id : TYPES.event_bets) =
  let p_newbetsTeamTwo : (address, tez) map = Map.add (Tezos.get_sender()) (Tezos.get_amount()) p_requested_event_id.betsTeamTwo in
  let p_newbetsTeamTwo_index : nat = (p_requested_event_id.betsTeamTwo_index + 1n) in
  (p_newbetsTeamTwo, p_newbetsTeamTwo_index)


let add_bet_team_two (p_requested_event_id : TYPES.event_bets) : TYPES.event_bets =
  let (newbetsTeamTwo, newbetsTeamTwo_index) : ((address, tez) map * nat) = match (Map.find_opt (Tezos.get_sender()) p_requested_event_id.betsTeamTwo) with
    | Some prevAmount -> add_bet_team_two_amount_to_existing_user p_requested_event_id prevAmount
    | None -> add_bet_team_twoAmountToNewUser p_requested_event_id
  in
  let newbetsTeamTwo_total : tez = (p_requested_event_id.betsTeamTwo_total + Tezos.get_amount()) in
  let r_updatedEvent : TYPES.event_bets = {p_requested_event_id with betsTeamTwo = newbetsTeamTwo; betsTeamTwo_index = newbetsTeamTwo_index; betsTeamTwo_total = newbetsTeamTwo_total;} in
  (r_updatedEvent)


let add_bet (p_requested_event_id : nat)(teamOneBet : bool)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assert_not_manager_nor_oracle (Tezos.get_sender()) s.manager s.oracleAddress in
  let _ = ASSERT.assert_no_tez (Tezos.get_amount()) in
  let _ = ASSERT.assert_tez_lower_than_min (Tezos.get_amount()) s.betConfig.minBetAmount in
  let requested_event : TYPES.event_type = match (Big_map.find_opt p_requested_event_id s.events) with
    | Some event -> event
    | None -> failwith ERRORS.no_event_id
  in
  let _ = ASSERT.assert_betting_not_finalized (requested_event.isFinalized) in
  let _ = ASSERT.assert_betting_before_period_start (requested_event.startBetTime) in
  let _ = ASSERT.assert_betting_after_period_end (requested_event.closedBetTime) in
  let requested_event_bets : TYPES.event_bets = match (Big_map.find_opt p_requested_event_id s.events_bets) with
    | Some event -> event
    | None -> failwith ERRORS.no_event_bets
  in
  let updated_bet_event : TYPES.event_bets = if (teamOneBet)
    then ( let uEvent : TYPES.event_bets = add_bet_team_one requested_event_bets in (uEvent) )
    else ( let uEvent : TYPES.event_bets = add_bet_team_two requested_event_bets in (uEvent) )
  in
  let new_events_map : (nat, TYPES.event_bets) big_map = (Big_map.update p_requested_event_id (Some(updated_bet_event)) s.events_bets) in
  (([] : operation list), {s with events_bets = new_events_map;})


let make_transfer_op (addr : address ) ( value_won : tez ) (profit_quota : nat): operation =
  let quota_to_send : nat = abs(100n - profit_quota) in
  let value_to_send : tez = value_won * quota_to_send / 100n in
  let dest_opt : unit contract option = Tezos.get_contract_opt addr in
  let destination : unit contract = match dest_opt with
    | None    -> failwith "Not found"
    | Some ct -> ct
  in
  Tezos.transaction unit value_to_send destination

let compose_paiement ( winner_map : (address, tez) map ) ( total_value_bet : tez ) ( total_value_won : tez ) (profit_quota : nat) : operation list =
  let folded_op_list = fun (op_list, (address, bet_amount) : operation list * (address * tez) ) -> 
    let won_reward_percentage : nat = 10000000n * bet_amount / total_value_bet in
    let added_reward : tez =  total_value_won * won_reward_percentage / 10000000n in    
    let reward_to_distribute : tez = bet_amount + added_reward in
    let reward_op : operation = make_transfer_op address reward_to_distribute profit_quota in
    reward_op :: op_list
  in
  let empty_op_list : operation list = [] in
  Map.fold folded_op_list winner_map empty_op_list

let resolve_team_win (event_bets : TYPES.event_bets) (is_team_one_win : bool) (profit_quota : nat) : operation list =
  if (is_team_one_win)
  then 
    let _ = ASSERT.opponent_has_positive_bet (event_bets.betsTeamTwo_total) in
    compose_paiement event_bets.betsTeamOne event_bets.betsTeamOne_total event_bets.betsTeamTwo_total profit_quota
  else 
    let _ = ASSERT.opponent_has_positive_bet (event_bets.betsTeamOne_total) in
    compose_paiement event_bets.betsTeamTwo event_bets.betsTeamTwo_total event_bets.betsTeamOne_total profit_quota
  
let refund_bet (event_bets : TYPES.event_bets) (profit_quota : nat) : operation list =
  let folded_op_list = fun (op_list, (address, bet_amount) : operation list * (address * tez) ) -> 
    let refund_op : operation = make_transfer_op address bet_amount profit_quota in
    refund_op :: op_list
  in
  let empty_op_list : operation list = [] in
  let team_one_refund : operation list = Map.fold folded_op_list event_bets.betsTeamOne empty_op_list   in
  let total_refund    : operation list = Map.fold folded_op_list event_bets.betsTeamTwo team_one_refund in
  total_refund

let finalize_bet (p_requested_event_id : nat)(s : TYPES.storage) : (operation list * TYPES.storage) =
  let _ = ASSERT.assert_is_manager (Tezos.get_sender()) s.manager in
  let requested_event : TYPES.event_type = match (Big_map.find_opt p_requested_event_id s.events) with
    | Some event -> event
    | None -> failwith ERRORS.no_event_id
  in
  let _check_is_claimed : unit = assert_with_error (requested_event.is_claimed = False) ERRORS.event_already_claimed in
  let _ = ASSERT.assert_betting_finalized (requested_event.isFinalized) in
  let event_bets : TYPES.event_bets = match (Big_map.find_opt p_requested_event_id s.events_bets) with
    | Some event -> event
    | None -> failwith ERRORS.no_event_bets
  in
  let _ = ASSERT.assert_finalizing_before_period_end (requested_event.end_at) in
  let outcome_draw : bool = match requested_event.isDraw with
    | Some x -> x
    | None -> failwith ERRORS.bet_no_team_outcome
  in
  let profit_quota : nat = s.betConfig.retainedProfitQuota in
  let modified_events = Big_map.update p_requested_event_id (Some({ requested_event with is_claimed = True })) s.events in
  if outcome_draw
  then
    let op_list = refund_bet event_bets profit_quota in
    ((op_list : operation list), { s with events = modified_events })
  else
    let is_team_one_win : bool = match requested_event.isTeamOneWin with
    | Some x -> x
    | None -> failwith ERRORS.bet_no_team_outcome
    in
    let op_list = resolve_team_win event_bets is_team_one_win profit_quota in
    ((op_list : operation list), { s with events = modified_events })

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
let getEvent (p_requested_event_id, s : nat * TYPES.storage) : timestamp * TYPES.event_type =
  let requested_event : TYPES.event_type = match (Big_map.find_opt p_requested_event_id s.events) with
    | Some event -> event
    | None -> failwith ERRORS.no_event_id
  in
  (Tezos.get_now(), requested_event)