#import "../../../contracts/cameligo/oracle/callback/main.mligo" "CALLBACK"

(* Some types for readability *)
type taddr = (CALLBACK.parameter, CALLBACK.storage) typed_address
type contr = CALLBACK.parameter contract
type originated = {
    addr: address;
    taddr: taddr;
    contr: contr;
}

let plainTimestamp : timestamp = ("1970-01-01T00:00:01Z" : timestamp)

(* Base CALLBACK storage *)
let base_storage : CALLBACK.storage = {
    name = "";
    videogame = "";
    begin_at = plainTimestamp + 2000;
    end_at = plainTimestamp + 4000;
    modified_at = plainTimestamp;
    opponents = { team_one = ""; team_two = ""};
    is_finalized = false;
    is_draw = (None : bool option);
    is_team_one_win = (None : bool option);
    metadata = (Map.empty : (string, bytes) map);
}

let originate_from_file (initial_storage : CALLBACK.storage) : originated =
    let oraclePath = "contracts/cameligo/oracle/callback/main.mligo" in
    let iTres = Test.run (fun (x : CALLBACK.storage) -> x) initial_storage in
    let (callback_addr, _, _) = Test.originate_from_file oraclePath "main" ([] : string list) iTres 0mutez in
    let callback_taddress = (Test.cast_address callback_addr : (CALLBACK.parameter, CALLBACK.storage) typed_address) in
    let callback_contract = Test.to_contract callback_taddress in
    {
        contr=callback_contract;
        taddr=callback_taddress;
        addr=callback_addr;
    }