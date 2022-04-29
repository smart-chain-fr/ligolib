## Contract Shifumi

This contract implements a Shifumi game for 2 players. This smart contract implements a "commit & reveal" mecanism with chest allowing players to keep choice secret until all players have played. In order to motivate players to reveal their secret action, players must lock 10 mutez during "Commit" and they get back their 10 mutez once the secret action is "revealed".

Users can create a new session and specify players and the number of round.

Players can choose an action (Stone, Paper, Cisor) secretly and commit their secret choice. 
Once all players have chosen their secret action, they can reveal it.

Players can reveal their secret action and commit their secret choice.
Once all players have revealed their secret action (for the current round), the result for this round is computed and the session goes to the next round. The result of the session is automatically computed once all rounds have been played.

The smart contract provides an on-chian view for retrieving the session information:
- the status of a session (Inplay, Winner, Draw)
- winners for each round

In the case of a player refusing to play (and keep the session stuck), an entrypoint has been provided to claim victory for 10 minutes of inactivity.

### Makefile usage 

The repository provides a Makefile for compiling/testing/deploying the smart contract Shifumi. All makefile targets are described with the `make` command.

### Compile Shifumi contract 

The repository provides a Makefile for compiling the smart contract Shifumi.
```
make compile
```
It compiles the smart contract in TZ file and also in the JSON format 

### Test Shifumi contract 

The repository provides a Makefile for testing the smart contract Shifumi.
```
make test
```

### Test Shifumi contract 

The repository provides a deployment script for deploying the smart contract Shifumi.
```
make deploy
```

It is based on a .env file that contains deployment information:
```
ADMIN_PK - private key
ADMIN_ADDRESS - public key
RPC - URL of the RPC node that will process the transaction 
```
