## Contract VIN (Vinus In Numeris)

This contract implements a factory of FA2 NFT. Each FA2 contract represents a collection of wine bottles. Wine bottles are represented by tokens inside a FA2 contract.
When originating a collection of bottle, 
- the creator must specify a collection name and a QR code for each bottle.
- the creator owns all bottles of the collection

The creator of the collection can also add new bottles to his collection anytime (with the *Mint* entrypoint)

A bottle owner can transfer one or more bottle to someone else (with the *Transfer* entrypoint)


A collection of bottles is represented by a FA2 contract. The implementation of the FA2 introduces:
- a admin address on the storage which represents the creator of the FA2 contract 
- a *Mint* entrypoint that allows the creator of the FA2 to create new tokens inside the NFT contract
- a *token_usage* map that count the number of transfer of a bottle
- a *token_usage* view for retrieving the number of transfer of a bottle (for a given token_id) 

![](wine_factory.png)

### Compilation

A makefile is provided to compile the "Factory" smart contract, and to launch tests.
```
cd src/cameligo/
make compile
make test
```

### Tests

A makefile is provided to launch tests.
```
cd src/cameligo/
make test
```

### Deployment

A typescript script for deployment is provided to originate the smart contrat. This deployment script relies on .env file which provides the RPC node url and the deployer public and private key.

```
cd src/cameligo
make deploy
```
