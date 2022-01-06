#include "advisor_types.ligo"

function request(const _p : unit; const s : advisorStorage) : advisorFullReturn is
block { 
    const c_opt : option(contract(unit)) = Tezos.get_entrypoint_opt("%sendValue", s.indiceAddress);
    const destinataire : contract(unit) = case c_opt of
    | Some(c) -> c
    | None -> (failwith("indice cannot send its value") : contract(unit))
    end;
    const op : operation = Tezos.transaction(unit, 0mutez, destinataire);
    const txs : list(operation) = list [ op; ];
 } with (txs, s)

function execute(const indiceVal : int; var s : advisorStorage) : advisorFullReturn is
block { 
    s.result := s.algorithm(indiceVal)
 } with ((nil : list(operation)), s)


function change(const p : advisorAlgo; var s : advisorStorage) : advisorFullReturn is
block { 
    s.algorithm := p;
 } with ((nil : list(operation)), s)

function advisorMain(const ep : advisorEntrypoints; const store : advisorStorage) : advisorFullReturn is
block { 
    const ret : advisorFullReturn = case ep of 
    | ReceiveValue(p) -> execute(p, store)
    | RequestValue(p) -> request(p, store)
    | ChangeAlgorithm(p) -> change(p, store)
    end;
 } with ret
