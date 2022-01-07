# Multi signature

This exeample is meant to illustrate a transaction requiring multiple people's confirmation before the operation is executed. With this MVP example smart-contrat, we show how to use multisig-type confirmation from M of N signers in order to send an operation. In this example, we will bind a call to a token transfer from another smart-contrat, since it’s the most classic use case ( Fungible Asset 1.2 ).

## The multisig pattern

Step Zero : deploy the contract with desired parameters and bind it to the entrypoint to execute. Each time a multisignature is required :

1. A signer propose a new operation execution with parameters, containing a time period within a maximum range
2. M of N possible signers submit an approval transaction to the smart-contrat
3. When the last required signer submits their approval transaction and the threshold is obtained, the resulting original transaction of the first signer is executed
4. If no quorum is established within the max_duration_in_sec, the operation will never execute

Any number of operations can be in valid execution at the same time.

The multisig contract can be invoked to request any operation on other smart contracts.

## Content

The `src` directory contains 3 directories:
- pascaligo: for smart contracts implementation in Pascaligo and `ligo` command lines for simulating all entrypoints
- cameligo: for smart contracts implementation in cameligo and `ligo` command lines for simulating all entrypoints
- jsligo: for smart contracts implementation in JSligo and `ligo` command lines for simulating all entrypoints
