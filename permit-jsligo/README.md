# permit-cameligo

This example contract implements an FA2 multi-asset contract with a
[TZIP-17](https://tzip.tezosagora.org/proposal/tzip-17/) extension.

In this implementation, permits can be submitted and consumed in [**separate-steps**](https://gitlab.com/tezos/tzip/-/blob/master/proposals/tzip-17/tzip-17.md#separate-step-permit).

## Why permits?

Permits have 2 main use cases:

- making gasless transaction
- avoiding manipulating operators (FA2) or allowances (FA1.2) when a transaction
must be done by a third-party

## Requirements

The contract is written in `cameligo` flavour of [LigoLANG](https://ligolang.org/),
to be able to compile the contract, you need either:

- a [ligo binary](https://ligolang.org/docs/intro/installation#static-linux-binary),
  in this case, to use the binary, you need to have set up a `LIGO` environment variable,
  pointing to the binary (see [Makefile](./Makefile))
- or [docker](https://docs.docker.com/engine/install/)

For deploy scripts, you also need to have [nodejs](https://nodejs.org/en/) installed,
up to version 14 and docker if you wish to deploy on a sandbox.

## Usage

1. Run `make install` to install dependencies
2. Run `make` to see available commands

## Use case: taco shop loyalty program

A potential use case is the digitalization of the good old loyalty card.  

### Loyalty Token creation

Expanding on the taco shop tutorial, let's say Pedro creates a new token to
reward his customers.

```mermaid
sequenceDiagram
  actor Pedro
  participant FA2
  Note left of Pedro: Pedro create a token
  Pedro->>FA2: Create_token
```

### Token distribution

Pedro rewards his customers with one token for each taco bought.

```mermaid
sequenceDiagram
  actor Pedro
  participant FA2
  Note left of Pedro: Pedro mint one token to<br> reward tacos buyers
  Pedro->>FA2: Mint_token
```

### Permit creation

Alicia is a regular client of the taco shop.  
She already accumulated 10 tokens, which can be exchanged for a free taco.  
One day, she happens to be out of tez, so she decides to use her tokens to pay.

So, she asks Pedro to create a permit.  
The permitted action will be the transfer of 10 tokens from Alicia to Pedro.  
Once Pedro has verified the permit parameters given by Alicia, he calls the smart
contract with them, registering the permit.

```mermaid
sequenceDiagram
  actor Alicia
  actor Pedro
  participant FA2
  Note left of Alicia: Alicia signs the transfer parameters
  Alicia->>Pedro: send public key, signature, hash
  Note left of Pedro: Pedro registers Alicia request by creating a permit<br> with her public key, signature and hash.
  Pedro->>FA2: Permit(key, (signature, bytes))
```

### Permit consumption

The last step consists in Alicia asking Pedro to consume the permit, by revealing
him the parameters she used for the permit creation, allowing Pedro to call the
`transfer` entrypoint with these parameters, actually consuming the permit.

```mermaid
sequenceDiagram
  actor Alicia
  actor Pedro
  participant FA2
  Note left of Alicia: Alicia reveals the parameters<br> used for the previously created permit.
  Alicia->>Pedro: reveal params
  Note left of Pedro: Pedro calls the transfer entry point for Alicia
  Pedro->>FA2: Transfer
```

## Entrypoints

On top of FA2 standard, the following entrypoints are implemented:

- `permit`: allows any sender to register a permit.
- `setExpiry`: allows any sender to change its expiry configuration for its own permits.  
  (intended camel case to comply with tzip-17)
- `transfer`: overrides FA2 `transfer` to add the handling of permitted parameters.

Additionally, for the use case presentation, 3 entrypoints have been added:

- `create_token`: creates a token.
- `mint_token`: mint a token.
- `burn_token`: burn a token.
- `set_admin`: to set the authorized account for the 3 above entry points.

## Smart Contract Data Types

``` mermaid
classDiagram
    Permit <|-- Storage
    UserExpiry <|-- Storage
    PermitExpiry <|-- Storage 

    class Storage {
        defaultExpiry: nat
        counter: nat
    }

    class Permit{
        type t
    }

    class UserExpiry {
        type t
        get(address)
        set(address, nat)
    }

    class PermitExpiry {
        type t
        get(address, bytes)
        set(address, bytes, nat)
    }
```

## Resources

- <https://news.ecadlabs.com/understanding-permits-on-tezos-tzip-17-standard-7e470684265c>
- <https://github.com/oxheadalpha/smart-contracts>
