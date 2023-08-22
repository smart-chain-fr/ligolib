#import "ligo-extendable-fa2/lib/multi_asset/fa2.mligo" "FA2"

type storage = FA2.storage

type extension = unit

type extended_storage = extension storage

type parameter = [@layout:comb]
    | Transfer of FA2.transfer
    | Balance_of of FA2.balance_of
    | Update_operators of FA2.update_operators

let main (p, s : parameter * extended_storage) : operation list * extended_storage =
    match p with
        Transfer                   p -> FA2.transfer p s
        | Balance_of               p -> FA2.balance_of p s
        | Update_operators         p -> FA2.update_ops p s
 

let assert_token_exist (s : extended_storage) (token_id : nat) : unit  =
    match (Big_map.find_opt token_id s.token_metadata) with
        None -> failwith FA2.Errors.undefined_token
        | Some meta -> assert_with_error (meta.token_id = token_id) FA2.Errors.undefined_token 

let get_balance (s : extended_storage) (owner:address) (token_id:nat) : nat =
    let () = assert_token_exist s token_id in
    FA2.Ledger.get_for_user s.ledger owner token_id

[@view] let get_balance (p, s : address * extended_storage) : nat =
    get_balance s p 0n