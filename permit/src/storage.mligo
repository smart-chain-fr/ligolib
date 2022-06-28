#import "ligo-generic-fa2/lib/multi_asset/fa2.mligo" "FA2"
#import "./errors.mligo" "Errors"
#import "./extension.mligo" "Extension"

type storage = FA2.storage
type extension = Extension.t
type t = extension storage

let get_token_metadata (s:t) = s.token_metadata
let set_token_metadata (s:t) (token_metadata:FA2.TokenMetadata.t) =
    {s with token_metadata = token_metadata}

let add_new_token (md:FA2.TokenMetadata.t) (token_id : nat) (data:FA2.TokenMetadata.data) =
    let () = assert_with_error (not (Big_map.mem token_id md)) Errors.token_exist in
    let md = Big_map.add token_id data md in
    md
