## Contract Auction

This contract implements an auction that allows a user (seller) to propose to sell an NFT token. Other users are allowed to bid for this NFT.

When a user bid on an auction, he must send some XTZ (at least auctionPrice) taht will be locked on the contract.
If a second bidder makes a better bid (at least last_price + min_bp), then the first bidder is refunded.

When the period has passed the auction can be finalized.
When the auction is finalized, the "seller" receives the amount of the last bid, and the buyer receives the NFT token.

### Makefile usage 

The repository provides a Makefile for compiling/testing/deploying the smart contract Auction. All makefile targets are described with the `make` command.

### Compile Auction contract 

The repository provides a Makefile for compiling the smart contract Auction.
```
make compile
```
It compiles the smart contract in TZ file and also in the JSON format 

### Test Auction contract 

The repository provides a Makefile for testing the smart contract Auction.
```
make test
```

### Deploy Auction contract 

The repository provides a deployment script for deploying the smart contract Auction.
```
make deploy
```

It is based on a .env file that contains deployment information:
```
DEPLOYER_PK=
ADMIN_ADDRESS=
FEE_ADDRESS=
FACTORY_CONTRACT_ADDRESS=
MARKETPLACE_CONTRACT_ADDRESS=
AUCTION_CONTRACT_ADDRESS=

RPC=http://127.0.0.1:8733
```
