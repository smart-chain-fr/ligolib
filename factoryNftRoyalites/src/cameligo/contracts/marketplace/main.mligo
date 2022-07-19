#import "storage.mligo" "Storage"
#import "errors.mligo" "Errors"
#import "parameter.mligo" "Parameter"
#import "../generic_fa2/core/instance/NFT.mligo" "NFT_FA2"

type storage = Storage.t
type parameter = Parameter.t
type return = operation list * storage

let create_sell_proposal(param, store : Parameter.sell_proposal_param * Storage.t) : return = 
    // check if sender is the owner of the nft token
    let balanceOpt : nat option = Tezos.call_view "get_balance" (Tezos.sender, param.token_id) param.collectionContract in
    let balanceVal : nat = match balanceOpt with
    | None -> (failwith(Errors.unknownViewGetBalance) : nat)
    | Some (v) -> v
    in
    //let usageOpt : nat option = Tezos.call_view "token_usage" param.token_id param.collectionContract in
    //let usageVal : nat = match usageOpt with
    //| None -> (failwith(Errors.unknownViewTokenUsage) : nat)
    //| Some (v) -> v
    //in
    let _check_owner : unit = assert_with_error (balanceVal = 1n) Errors.not_owner in
    // Add new proposal
    let new_proposals = Big_map.add store.next_sell_id { owner=Tezos.sender; token_id=param.token_id; collectionContract=param.collectionContract; active=true; price=param.price } store.sell_proposals in
    let new_next_sell_id : nat = store.next_sell_id + 1n in 
    let new_active_proposals : nat set = Set.add store.next_sell_id store.active_proposals in 

    // approve this contract as operator
    //let collection_approve_dest_opt : NFT_FA2.update_operators contract option = Tezos.get_entrypoint_opt "%update_operators" param.collectionContract in
    //let collection_approve_dest : NFT_FA2.update_operators contract = match collection_approve_dest_opt with
    //| None -> (failwith(Errors.unknown_fa2_contract): NFT_FA2.update_operators contract) 
    //| Some ct -> ct
    //in
    //let update_op : NFT_FA2.update_operators = [Add_operator({owner=Tezos.sender; operator=Tezos.self_address; token_id=param.token_id})] in
    //let op : operation = Tezos.transaction update_op 0mutez collection_approve_dest in

    (([] : operation list), { store with next_sell_id=new_next_sell_id; sell_proposals=new_proposals; active_proposals=new_active_proposals })


let accept_proposal(param, store : Parameter.buy_param * Storage.t) : return =
    let _check_among_active_proposals : unit = assert_with_error (Set.mem param.proposal_id store.active_proposals) Errors.proposal_not_active in 
    let propal : Storage.sell_proposal = match Big_map.find_opt param.proposal_id store.sell_proposals with
    | None -> (failwith(Errors.unknown_proposal) : Storage.sell_proposal)
    | Some pr -> pr
    in
    let _check_status : unit = assert_with_error(propal.active) Errors.proposal_not_active in
    let _check_amount : unit = assert_with_error(Tezos.amount >= propal.price) Errors.wrong_amount in
    
    let new_propal = { propal with active=false } in
    let new_active_proposals : nat set = Set.remove param.proposal_id store.active_proposals in
    let new_proposals = Big_map.update param.proposal_id (Some(new_propal)) store.sell_proposals in

    // transfer Tez to owner
    let dest_opt : unit contract option = Tezos.get_contract_opt propal.owner in
    let destination : unit contract = match dest_opt with
    | None -> (failwith("Unknwon owner"): unit contract) 
    | Some c -> c
    in
    let op : operation = Tezos.transaction unit propal.price destination in
    
    // unapprove this contract as operator
    //let collection_approve_dest_opt : NFT_FA2.update_operators contract option = Tezos.get_entrypoint_opt "%update_operators" propal.collectionContract in 
    //let collection_approve_dest : NFT_FA2.update_operators contract = match collection_approve_dest_opt with
    //| None -> (failwith(Errors.unknown_fa2_contract): NFT_FA2.update_operators contract) 
    //| Some ct -> ct
    //in
    //let update_op : NFT_FA2.update_operators = [Remove_operator({owner=propal.owner; operator=Tezos.self_address; token_id=propal.token_id})] in
    //let op1 : operation = Tezos.transaction update_op 0mutez collection_approve_dest in


    // transfer Nft to new_owner
    let collection_transfer_dest_opt : NFT_FA2.NFT.transfer contract option = Tezos.get_entrypoint_opt "%transfer" propal.collectionContract in
    let collection_transfer_dest : NFT_FA2.NFT.transfer contract = match collection_transfer_dest_opt with
    | None -> (failwith(Errors.unknown_fa2_contract): NFT_FA2.NFT.transfer contract) 
    | Some ct -> ct
    in
    let nft_transfer : NFT_FA2.NFT.transfer = [{from_=propal.owner; tx=[{to_=Tezos.sender; token_id=propal.token_id}]}] in
    let rest_tez_opt : tez option = Tezos.amount - propal.price in
    let rest_tez : tez = match rest_tez_opt with
    | None -> (failwith("missing tez for paying royalties") : tez)
    | Some rest -> rest
    in
    let op2 : operation = Tezos.transaction nft_transfer rest_tez collection_transfer_dest in
    
    ([op; op2;], { store with sell_proposals=new_proposals; active_proposals=new_active_proposals })

let main(ep, store : parameter * storage) : return =
    match ep with 
    | Sell p -> create_sell_proposal(p, store)
    | Buy p -> accept_proposal(p, store)

[@view] let get_proposal : (nat * storage) -> Storage.sell_proposal = 
   fun ((p, s) : (nat * storage)) -> 
      match Big_map.find_opt p s.sell_proposals with 
      | None -> (failwith("") : Storage.sell_proposal)
      | Some prop -> prop 

[@view] let active_proposals : (unit * storage) -> nat list = 
    fun ((_p, s) : (unit * storage)) -> 
        Set.fold (fun(acc, i : nat list * nat) -> i :: acc) s.active_proposals ([] : nat list)
          
