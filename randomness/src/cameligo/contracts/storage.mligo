#import "errors.mligo" "Errors"
#import "parameter.mligo" "Parameter"

module Types = struct
    type t = {
        participants : address set;
        secrets : (address, chest) map;
        decoded_payloads: (address, bytes) map;
        result : bytes option
    }
end

module Utils = struct

    // Once everybody has commit & reveal we compute some bytes as result
    let trigger(payloads : (address, bytes) map) : bytes option =
        let hash_payload = fun(acc, elt: bytes list * (address * bytes)) : bytes list -> (Crypto.keccak elt.1) :: acc in
        let pl : bytes list = Map.fold hash_payload payloads ([]:bytes list) in
        let hashthemall = fun(acc, elt: bytes option * bytes) : bytes option -> 
            match acc with 
            | None -> Some(elt)
            | Some pred -> Some(Crypto.keccak (Bytes.concat elt pred)) 
        in
        List.fold hashthemall pl (None : bytes option)

    // Sender commits its chest
    let commit(p, st : Parameter.Types.commit_param * Types.t) : operation list * Types.t =
        let _check_authorized : unit = assert_with_error (Set.mem Tezos.sender st.participants) "Not authorized" in
        let new_secrets = match Map.find_opt Tezos.sender st.secrets with
        | None -> Map.add Tezos.sender p.secret_action st.secrets
        | Some _x -> (failwith("Sender has already given its chest") : (address, chest) map)
        in
        (([] : operation list), { st with secrets=new_secrets })
        
    // Sender reveals its chest content
    let reveal(p, s : Parameter.Types.reveal_param * Types.t) : operation list * Types.t =
        let sender : address = Tezos.sender in
        let _check_authorized : unit = assert_with_error (Set.mem sender s.participants) "Not authorized" in
        // check all chest has been received
        let committed = fun (acc, elt : bool * address) : bool -> match Map.find_opt elt s.secrets with
            | None -> acc && false
            | Some _x -> acc && true
        in
        let _all_chests_committed = Set.fold committed s.participants true in

        let _check_all_chests : unit = assert_with_error (_all_chests_committed = true) "Missing some chest" in

        let (ck, secret) = p in
        let sender_chest : chest = match Map.find_opt sender s.secrets with
        | None -> failwith("Missing some chest")
        | Some ch -> ch
        in
        // open chest and stores the chest content
        let decoded_payload =
            match Tezos.open_chest ck sender_chest secret with
            | Ok_opening b -> b
            | Fail_timelock -> (failwith("Could not open chest: Fail_timelock") : bytes)
            | Fail_decrypt -> (failwith("Could not open chest: Fail_decrypt") : bytes)
        in
        let new_decoded_payloads = match Map.find_opt sender s.decoded_payloads with
        | None -> Map.add Tezos.sender decoded_payload s.decoded_payloads
        | Some _elt -> (failwith("Already revealed") : (address, bytes) map)
        in 
        // check all chest has been revealed
        let revealed = fun (acc, elt : bool * address) : bool -> match Map.find_opt elt new_decoded_payloads with
            | None -> acc && false
            | Some _x -> acc && true
        in
        let all_chests_revealed = Set.fold revealed s.participants true in
        if all_chests_revealed = true then
            (([] : operation list), { s with decoded_payloads=new_decoded_payloads; result=trigger(new_decoded_payloads) })  
        else
            (([] : operation list), { s with decoded_payloads=new_decoded_payloads })
end