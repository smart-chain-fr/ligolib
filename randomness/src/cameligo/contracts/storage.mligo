#import "errors.mligo" "Errors"
#import "parameter.mligo" "Parameter"
#import "bytes_utils.mligo" "Convert"

module Types = struct
    type t = {
        participants : address set;
        locked_tez : (address, tez) map;
        secrets : (address, chest) map;
        decoded_payloads: (address, bytes) map;
        result : bytes option;
        result_nat : nat option;
        last_seed : nat;
        max : nat;
        min: nat
    }
end

module Utils = struct

    let random_range (state0: nat) (state1:nat) (min:nat) (max:nat) = 
        let random (state0: nat) (state1: nat) = 
            let s0 = state0 in
            let s1 = state1 in
            let s1 =  s1 lxor (s1 lsl 23n) in 
            let s1 =  s1 lxor (s1 lsr 17n) in 
            let s1 =  s1 lxor s0 in 
            let s1 =  s1 lxor (s0 lsr 26n) in 
            s0 + s1 in
        let ns = random state0 state1 in 
        (ns, ns mod (max + 1n - min) + min)
    

    let trigger_to_nat(payloads, min, max, last_seed : (address, bytes) map * nat * nat * nat) : nat * nat =
        let hash_payload = fun(acc, elt: bytes list * (address * bytes)) : bytes list -> (Crypto.keccak elt.1) :: acc in
        let pl : bytes list = Map.fold hash_payload payloads ([]:bytes list) in
        let hashthemall = fun(acc, elt: bytes option * bytes) : bytes option -> 
            match acc with 
            | None -> Some(elt)
            | Some pred -> Some(Crypto.keccak (Bytes.concat elt pred)) 
        in
        let seed_bytes = List.fold hashthemall pl (None : bytes option) in
        let seed : nat = match seed_bytes with 
        | None -> (failwith("could not construct a hash") : nat)
        | Some hsh -> Convert.Utils.bytes_to_nat(hsh)
        in
        random_range last_seed seed min max

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
        let _check_amount : unit = assert_with_error (Tezos.amount >= 10mutez) "You must lock 10mutez" in
        let new_secrets = match Map.find_opt Tezos.sender st.secrets with
        | None -> Map.add Tezos.sender p.secret_action st.secrets
        | Some _x -> (failwith("Sender has already given its chest") : (address, chest) map)
        in
        let new_locked : (address, tez) map = match Map.find_opt Tezos.sender st.locked_tez with
        | None -> Map.add Tezos.sender Tezos.amount st.locked_tez
        | Some val -> Map.update Tezos.sender (Some(val + Tezos.amount)) st.locked_tez
        in
        (([] : operation list), { st with secrets=new_secrets; locked_tez=new_locked })
        
    // Sender reveals its chest content
    let reveal(p, s : Parameter.Types.reveal_param * Types.t) : operation list * Types.t =
        let sender_address : address = Tezos.sender in
        let _check_amount : unit = assert_with_error (Tezos.amount = 0mutez) "You must not send tez (reveal)" in
        let _check_authorized : unit = assert_with_error (Set.mem sender_address s.participants) "Not authorized" in
        // check all chest has been received
        let committed = fun (acc, elt : bool * address) : bool -> match Map.find_opt elt s.secrets with
            | None -> acc && false
            | Some _x -> acc && true
        in
        let _all_chests_committed = Set.fold committed s.participants true in

        let _check_all_chests : unit = assert_with_error (_all_chests_committed = true) "Missing some chest" in

        let (ck, secret) = p in
        let sender_chest : chest = match Map.find_opt sender_address s.secrets with
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
        let new_decoded_payloads = match Map.find_opt sender_address s.decoded_payloads with
        | None -> Map.add Tezos.sender decoded_payload s.decoded_payloads
        | Some _elt -> (failwith("Already revealed") : (address, bytes) map)
        in 
        // check all chest has been revealed
        let revealed = fun (acc, elt : bool * address) : bool -> match Map.find_opt elt new_decoded_payloads with
            | None -> acc && false
            | Some _x -> acc && true
        in
        let new_locked : (address, tez) map = match Map.find_opt Tezos.sender s.locked_tez with
        | None -> failwith("ERROR user balance should be positive")
        | Some val -> Map.update Tezos.sender (Some(val - 10mutez)) s.locked_tez
        in
        let dest_opt : unit contract option = Tezos.get_contract_opt Tezos.sender in
        let destination : unit contract = match dest_opt with
        | None -> failwith("Unknown sender")
        | Some ct -> ct
        in
        let op : operation = Tezos.transaction unit 10mutez destination in 

        let all_chests_revealed = Set.fold revealed s.participants true in
        if all_chests_revealed = true then
            let (seed, value) = trigger_to_nat(new_decoded_payloads, s.min, s.max, s.last_seed) in
            ([op], { s with decoded_payloads=new_decoded_payloads; locked_tez=new_locked; result=trigger(new_decoded_payloads); result_nat=(Some(value)); last_seed=seed })  
        else
            ([op], { s with decoded_payloads=new_decoded_payloads; locked_tez=new_locked })

    let reset (param, store : Parameter.Types.reset_param * Types.t) : operation list * Types.t =
        // clean secrets_chest and decoded_payloads
        let _check_amount : unit = assert_with_error (Tezos.amount = 0mutez) "You must not send tez (reset)" in
        (([] : operation list), { store with 
            decoded_payloads=(Map.empty : (address, bytes) map); 
            secrets=(Map.empty : (address, chest) map); 
            result=(None : bytes option); 
            result_nat=(None : nat option);
            min=param.min;
            max=param.max 
        })

end