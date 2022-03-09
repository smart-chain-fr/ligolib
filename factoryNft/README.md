## Contract factory NFT

This contract is a template of factory NFT. The factory contract uses the FA2 ligo library (packaged with ligo)

### Usage

A makefile is provided to compile the "Factory" smart contract, and to launch tests.
```
make compile
make test
```
### Deployment

A typescript script for deployment is provided to originate the smart contrat. This deployment script relies on .env file which provides the RPC node url and the deployer public and private key.

```
tsc deploy.ts --resolveJsonModule -esModuleInterop
node deploy.js
```
