#import "errors.mligo" "Errors"
#import "parameter.mligo" "Parameter"
#import "bytes_utils.mligo" "Convert"

module Types = struct
    type t = {
        participants : address set;
        locked_tez : (address, tez) map;
        secrets : (address, chest) map;
        decoded_payloads: (address, bytes) map;
        result_nat : nat option;
        last_seed : nat;
        max : nat;
        min: nat
    }
end

module Utils = struct

    // Apply Mersenne twister algorithm to get a random number between min an max
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
    
    // Once everybody has commit & reveal we can compute bytes seed
    let build_seed_bytes(payloads : (address, bytes) map) : bytes option =
        // hash all decoded payloads
        let hash_payload = fun(acc, elt: bytes list * (address * bytes)) : bytes list -> (Crypto.keccak elt.1) :: acc in
        let pl : bytes list = Map.fold hash_payload payloads ([]:bytes list) in
        // combine all hashes (concat and hash again)
        let hashthemall = fun(acc, elt: bytes option * bytes) : bytes option -> 
            match acc with 
            | None -> Some(elt)
            | Some pred -> Some(Crypto.keccak (Bytes.concat elt pred)) 
        in
        List.fold hashthemall pl (None : bytes option)

    // Compute a seed based on decoded chest payloads
    let build_random_nat(payloads, min, max, last_seed : (address, bytes) map * nat * nat * nat) : nat * nat =
        // Compute a seed based on decoded chest payloads
        let seed_bytes = build_seed_bytes payloads in 
        // convert hash seed into nat seed
        let seed : nat = match seed_bytes with 
        | None -> (failwith("could not construct a hash") : nat)
        | Some hsh -> Convert.Utils.bytes_to_nat(hsh)
        in
        // generate a random nat (between range) based on the computed nat seed
        random_range last_seed seed min max

end