#import "../../../contracts/cameligo/betting/callback/main.mligo" "Callback"

(* Some types for readability *)
type taddr = (Callback.parameter, Callback.storage) typed_address
type contr = Callback.parameter contract
type originated = {
    addr: address;
    taddr: taddr;
    contr: contr;
}

let plain_timestamp : timestamp = ("1970-01-01T00:00:01Z" : timestamp)

(* Base Callback storage *)
let base_storage (bettingAddr : address) : Callback.storage = {
    name              = "";
    videogame         = "";
    begin_at          = plain_timestamp + 2048;
    end_at            = plain_timestamp + 4096;
    modified_at       = plain_timestamp;
    opponents         = { team_one = ""; team_two = ""};
    is_finalized       = false;
    is_draw            = (None : bool option);
    is_team_one_win      = (None : bool option);
    start_bet_time      = plain_timestamp + 360;
    closed_bet_time     = plain_timestamp + 3072;
    bets_team_one       = (Map.empty : (address, tez) map);
    bets_team_one_index = 0n;
    bets_team_one_total = 0mutez;
    bets_team_two       = (Map.empty : (address, tez) map);
    bets_team_two_index = 0n;
    bets_team_two_total = 0mutez;
    metadata          = (Map.empty : (string, bytes) map);
    bettingAddr       = bettingAddr;
}

let originate_from_file (initial_storage : Callback.storage) : originated =
    let betting_path           = "contracts/cameligo/betting/callback/main.mligo" in
    let iTres                 = Test.run (fun (x : Callback.storage) -> x) initial_storage in
    let (callback_addr, _, _) = Test.originate_from_file betting_path "main" ([] : string list) iTres 0mutez in
    let callback_taddress     = (Test.cast_address callback_addr : (Callback.parameter, Callback.storage) typed_address) in
    let callback_contract     = Test.to_contract callback_taddress in
    {
        contr=callback_contract;
        taddr=callback_taddress;
        addr=callback_addr;
    }
