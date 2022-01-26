#import "parameter.mligo" "Parameter"
#import "conditions.mligo" "Conditions"

module Types = struct
    type versions = (string, address) map
    type t = {
        owner    : address;
        version  : string;
        versions : versions
    }
end

module Utils = struct
    let transfer_ownership (s:Types.t) (new_owner:address) =
        let _ = Conditions.amount_must_be_zero_tez() in
        let _ = Conditions.only_sender(s.owner) in
        { s with owner = new_owner }

    let add_version (s:Types.t) (v:Parameter.Types.new_version_params) =
        let _ = Conditions.amount_must_be_zero_tez() in
        let _ = Conditions.only_sender(s.owner) in
        { s with versions = Map.add v.label v.dest s.versions }

    let set_version (s:Types.t) (v:string) =
        let _ = Conditions.amount_must_be_zero_tez() in
        let _ = Conditions.only_sender(s.owner) in
        { s with version = v} 
end
