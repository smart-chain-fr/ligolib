## Contract Super Wine

This contract implements a factory of FA2 NFT which handles royalties on the FA2 level (on primary market). Each FA2 contract represents a collection of poems. Poems are represented by tokens inside a FA2 contract as non fungible tokens.
When originating a collection of poems, 
- the creator must specify a collection name and a QR code for poem (the QR code is the hash of the poem) and an author.
- the creator owns all minted poems of the collection

The creator of the collection can also add new poems to his collection anytime (with the *Mint* entrypoint)

A bottle owner can transfer one or more bottle to someone else (with the *Transfer* entrypoint) and must specify a tez amount for sending royalties to the author. 


A collection of poems is represented by a FA2 contract. The implementation of the FA2 introduces:
- a admin address on the storage which represents the creator of the FA2 contract 
- a *Mint* entrypoint that allows the creator of the FA2 to create new tokens inside the NFT contract
- a specialized Transfer entrypoint which handles transfer of the Nft and the royalties. 


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
