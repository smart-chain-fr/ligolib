# ligo_tutorial_fundadvisor

This tutorial is meant to illustrate the communication between contracts (with `get_entrypoint_opt` LIGO function) and lambda pattern which allows to modify a contract already deployed. It deals with implementing, deploying and interacting with Tezos smart contracts.


## The Fund and its advisor (i.e. "L'indice et le conseiller")

The `indice` contract represents a fund value and the `advisor` contract gives an advice on investing on this fund. 


### Transaction workflow

The `advisor` contract can be invoked to request the fund value to the `indice` contract (via a transaction). The `indice` contract receives the request (transaction) and sends back the requested value. When `advisor` contract receives the fund value it can apply the "algorithm" to check it is worth investing !

![](Indice_advisor.png)

The resulting advice is stored in the storage (in `result` field).

### Lambda pattern

The real business logic of the `advisor` smart contract lies in the lambda function which is defined in the storage. The storage is vowed to be modified so as for the business logic (lambda).

So an entrypoint `ChangeAlgorithm` is provided to modify the algorithm that computes the worth of investment. 


## Content

The `src` directory contains pascal-ligo smart contracts implementation and related Michelson code. 

The `videos` directory contains live-coding streams of implementing and testing smart contracts (with `ligo` and `tezos-client` in a sandbox).
