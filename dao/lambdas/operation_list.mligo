#import "../src/lambda.mligo" "Lambda"
#import "tezos-ligo-fa2/lib/fa2/asset/single_asset.mligo" "SingleAsset"

(* Sample lambda that calls an FA2 transfer entrypoint *)

let lambda_ : Lambda.operation_list =
  fun () ->
    match (Tezos.get_entrypoint_opt
             "%transfer"
             ("KT1QAShr81NcaFZyJR4srfYGuvPyD8ibbMtT"
              : address)
           : SingleAsset.transfer contract option)
    with
      None -> failwith ("TOKEN_CONTRACT_NOT_FOUND")
    | Some (c) ->
        let transfer_requests =
          ([({from_ =
                ("KT1BWSmjEhEknnBWSYrrSdhH217osBbwdVos"
                 : address);
              tx =
                ([{to_ =
                     ("tz1burnburnburnburnburnburnburjAYjjX"
                      : address);
                   amount = 4000n}]
                 : SingleAsset.atomic_trans list)})]
           : SingleAsset.transfer) in
        let op =
          Tezos.transaction transfer_requests 0mutez c in
        [op]
