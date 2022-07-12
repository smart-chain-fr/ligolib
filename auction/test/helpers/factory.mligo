#import "../../contracts/factory/main.mligo" "Factory"

(* Some types for readability *)
type taddr = (Factory.parameter, Factory.storage) typed_address
type contr = Factory.parameter contract
type originated = {
    addr: address;
    taddr: taddr;
    contr: contr;
}

(* Base Factory storage *)
let base_storage : Factory.storage = {
    all_collections=(Big_map.empty : (Factory.Storage.collectionContract, Factory.Storage.collectionOwner) big_map);
    owned_collections=(Big_map.empty : (Factory.Storage.collectionOwner, Factory.Storage.collectionContract list) big_map);
}

(* Originate a Factory contract with given init_storage storage *)
let originate (init_storage : Factory.storage) =
    let (taddr, _, _) = Test.originate Factory.main init_storage 0mutez in
    let contr = Test.to_contract taddr in
    let addr = Tezos.address contr in
    {addr = addr; taddr = taddr; contr = contr}

(* Call entry point of Factory contr contract *)
let call (p, contr : Factory.parameter * contr) =
    Test.transfer_to_contract contr (p) 0mutez