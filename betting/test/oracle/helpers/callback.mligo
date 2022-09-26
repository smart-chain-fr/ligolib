#import "../../../src/contracts/cameligo/oracle/callback/main.mligo" "Callback"

(* Some types for readability *)
type taddr = (Callback.parameter, Callback.storage) typed_address
type contr = Callback.parameter contract
type originated = {
    addr: address;
    taddr: taddr;
    contr: contr;
}

let plain_timestamp : timestamp = ("1970-01-01T00:00:01Z" : timestamp)

type game_status = Ongoing | Team1Win| Team2Win | Draw

(* Base Callback storage *)
let base_storage : Callback.storage = {
    name = "";
    videogame = "";
    begin_at = plain_timestamp + 2000;
    end_at = plain_timestamp + 4000;
    modified_at = plain_timestamp;
    opponents = { team_one = ""; team_two = ""};
    game_status = Ongoing;
    metadata = (Map.empty : (string, bytes) map);
}

let originate_from_file (initial_storage : Callback.storage) : originated =
    let oracle_path = "../../../src/contracts/cameligo/oracle/callback/main.mligo" in
    let iTres = Test.run (fun (x : Callback.storage) -> x) initial_storage in
    let (callback_addr, _, _) = Test.originate_from_file oracle_path "main" ([] : string list) iTres 0mutez in
    let callback_taddress = (Test.cast_address callback_addr : (Callback.parameter, Callback.storage) typed_address) in
    let callback_contract = Test.to_contract callback_taddress in
    {
        contr=callback_contract;
        taddr=callback_taddress;
        addr=callback_addr;
    }