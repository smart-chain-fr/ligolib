## Contract Escrow

### Compile Escrow contract 
- generates michelson code 
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile contract src/cameligo/payment.mligo -e main > src/cameligo/compiled/payment.tz
```
- generates michelson code in JSON format
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile contract src/cameligo/payment.mligo --michelson-format json -e main > src/cameligo/compiled/payment.json
```

### Compile Escrow storage
- with no currencies, no escrows, no judges
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile storage src/cameligo/payment.mligo '{admin=("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address); currencies=(Map.empty : (currency, address) map); escrows=(Map.empty : (escrow_id, escrow) map); judges=(Map.empty : (nat, address) map); votingContract=("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)}' -e main
```

- with 1 escrow, 1 currencies, no judges
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile storage src/cameligo/payment.mligo '{admin=("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address); currencies=Map.literal[("TZBTC", ("KT1MdenM9nqSvRnoLinXwU6dKYkug6upkezM" : address))]; escrows=Map.literal[("escrow1", {currency="TZBTC"; amount=100n; buyer=("tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur" : address); seller=("tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF" : address); escrowContract=(None : address option); cancelled=false; released=false; paid=false})]; judges=(Map.empty : (nat, address) map); votingContract=("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)}' -e main
```

 

### Compile parameter (with ligo compiler) into Michelson expression

- For entrypoint add_currency
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile parameter src/cameligo/payment.mligo 'add_currency("ETHTZ", ("KT1RmgE6SFgHFbKZDQsCCBz8jLvFyDd3z1su" : address))' -e main
```

- For entrypoint delete_currency
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile parameter src/cameligo/payment.mligo 'delete_currency("TZBTC")' -e main
```

- For entrypoint Pay
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile parameter src/cameligo/payment.mligo 'Pay({currency="TZBTC"; amount=100n; escrow_id="escrow1"})' -e main
```

- For entrypoint CancelEscrow
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile parameter src/cameligo/payment.mligo 'CancelEscrow("escrow1")' -e main
```

- For entrypoint ReleaseEscrow
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile parameter src/cameligo/payment.mligo 'ReleaseEscrow("escrow1")' -e main
```

- For entrypoint SetEscrowcontract
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile parameter src/cameligo/payment.mligo 'SetEscrowcontract("escrow1", ("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi":address))' -e main
```

- For entrypoint set_admin
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile parameter src/cameligo/payment.mligo 'set_admin(("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK":address))' -e main
```


### Simulate execution of entrypoints (with ligo compiler)

- For entrypoint add_currency (will fail)
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/cameligo/payment.mligo  'add_currency("ETHTZ", ("KT1RmgE6SFgHFbKZDQsCCBz8jLvFyDd3z1su" : address))' '{admin=("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address); currencies=Map.literal[("TZBTC", ("KT1MdenM9nqSvRnoLinXwU6dKYkug6upkezM" : address))]; escrows=Map.literal[("escrow1", {currency="TZBTC"; amount=100n; buyer=("tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur" : address); seller=("tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF" : address); escrowContract=(None : address option); cancelled=false; released=false; paid=false})]; judges=(Map.empty : (nat, address) map); votingContract=("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)}' -e main
```

- For entrypoint add_currency (sent with admin -> SUCCESS)
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/cameligo/payment.mligo  'add_currency("ETHTZ", ("KT1RmgE6SFgHFbKZDQsCCBz8jLvFyDd3z1su" : address))' '{admin=("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address); currencies=Map.literal[("TZBTC", ("KT1MdenM9nqSvRnoLinXwU6dKYkug6upkezM" : address))]; escrows=Map.literal[("escrow1", {currency="TZBTC"; amount=100n; buyer=("tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur" : address); seller=("tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF" : address); escrowContract=(None : address option); cancelled=false; released=false; paid=false})]; judges=(Map.empty : (nat, address) map); votingContract=("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)}' -e main --sender tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK
```

- For entrypoint delete_currency (will fail because not admin)
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/cameligo/payment.mligo  'delete_currency("TZBTC")' '{admin=("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address); currencies=Map.literal[("TZBTC", ("KT1MdenM9nqSvRnoLinXwU6dKYkug6upkezM" : address))]; escrows=Map.literal[("escrow1", {currency="TZBTC"; amount=100n; buyer=("tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur" : address); seller=("tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF" : address); escrowContract=(None : address option); cancelled=false; released=false; paid=false})]; judges=(Map.empty : (nat, address) map); votingContract=("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)}' -e main
```

- For entrypoint delete_currency (will fail because currency_unknown)
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/cameligo/payment.mligo  'delete_currency("ETHTZ")' '{admin=("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address); currencies=Map.literal[("TZBTC", ("KT1MdenM9nqSvRnoLinXwU6dKYkug6upkezM" : address))]; escrows=Map.literal[("escrow1", {currency="TZBTC"; amount=100n; buyer=("tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur" : address); seller=("tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF" : address); escrowContract=(None : address option); cancelled=false; released=false; paid=false})]; judges=(Map.empty : (nat, address) map); votingContract=("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)}' -e main --sender tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK
```

- For entrypoint delete_currency 
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/cameligo/payment.mligo  'delete_currency("TZBTC")' '{admin=("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address); currencies=Map.literal[("TZBTC", ("KT1MdenM9nqSvRnoLinXwU6dKYkug6upkezM" : address))]; escrows=Map.literal[("escrow1", {currency="TZBTC"; amount=100n; buyer=("tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur" : address); seller=("tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF" : address); escrowContract=(None : address option); cancelled=false; released=false; paid=false})]; judges=(Map.empty : (nat, address) map); votingContract=("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)}' -e main --sender tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK
```
=> risky because some escrow might get stuck (no more currency to transfer)

- For entrypoint Pay (will fail -> no entrypoint transfer)
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/cameligo/payment.mligo 'Pay({currency="TZBTC"; amount=100n; escrow_id="escrow1"})'  '{admin=("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address); currencies=Map.literal[("TZBTC", ("KT1MdenM9nqSvRnoLinXwU6dKYkug6upkezM" : address))]; escrows=Map.literal[("escrow1", {currency="TZBTC"; amount=100n; buyer=("tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur" : address); seller=("tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF" : address); escrowContract=(None : address option); cancelled=false; released=false; paid=false})]; judges=(Map.empty : (nat, address) map); votingContract=("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)}' -e main --sender tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur
```

- For entrypoint Pay (will fail -> sender is not buyer)
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/cameligo/payment.mligo 'Pay({currency="TZBTC"; amount=100n; escrow_id="escrow1"})'  '{admin=("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address); currencies=Map.literal[("TZBTC", ("KT1MdenM9nqSvRnoLinXwU6dKYkug6upkezM" : address))]; escrows=Map.literal[("escrow1", {currency="TZBTC"; amount=100n; buyer=("tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur" : address); seller=("tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF" : address); escrowContract=(None : address option); cancelled=false; released=false; paid=false})]; judges=(Map.empty : (nat, address) map); votingContract=("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)}' -e main --sender tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK
```

- For entrypoint Pay (will fail -> unknown_escrow)
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/cameligo/payment.mligo 'Pay({currency="TZBTC"; amount=100n; escrow_id="escrow2"})'  '{admin=("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address); currencies=Map.literal[("TZBTC", ("KT1MdenM9nqSvRnoLinXwU6dKYkug6upkezM" : address))]; escrows=Map.literal[("escrow1", {currency="TZBTC"; amount=100n; buyer=("tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur" : address); seller=("tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF" : address); escrowContract=(None : address option); cancelled=false; released=false; paid=false})]; judges=(Map.empty : (nat, address) map); votingContract=("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)}' -e main --sender tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur
```


- For entrypoint CancelEscrow sent by admin (will fail -> escrow not paid by buyer)
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/cameligo/payment.mligo 'CancelEscrow("escrow1")'  '{admin=("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address); currencies=Map.literal[("TZBTC", ("KT1MdenM9nqSvRnoLinXwU6dKYkug6upkezM" : address))]; escrows=Map.literal[("escrow1", {currency="TZBTC"; amount=100n; buyer=("tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur" : address); seller=("tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF" : address); escrowContract=(None : address option); cancelled=false; released=false; paid=false})]; judges=(Map.empty : (nat, address) map); votingContract=("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)}' -e main --sender tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK
```

- For entrypoint CancelEscrow sent by buyer (will fail -> should be sent by admin)
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/cameligo/payment.mligo 'CancelEscrow("escrow1")'  '{admin=("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address); currencies=Map.literal[("TZBTC", ("KT1MdenM9nqSvRnoLinXwU6dKYkug6upkezM" : address))]; escrows=Map.literal[("escrow1", {currency="TZBTC"; amount=100n; buyer=("tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur" : address); seller=("tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF" : address); escrowContract=(None : address option); cancelled=false; released=false; paid=false})]; judges=(Map.empty : (nat, address) map); votingContract=("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)}' -e main --sender tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur
```

- For entrypoint CancelEscrow sent by admin (will fail -> no transfer entrypoint)
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/cameligo/payment.mligo 'CancelEscrow("escrow1")'  '{admin=("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address); currencies=Map.literal[("TZBTC", ("KT1MdenM9nqSvRnoLinXwU6dKYkug6upkezM" : address))]; escrows=Map.literal[("escrow1", {currency="TZBTC"; amount=100n; buyer=("tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur" : address); seller=("tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF" : address); escrowContract=(None : address option); cancelled=false; released=false; paid=true})]; judges=(Map.empty : (nat, address) map); votingContract=("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)}' -e main --sender tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK
```


- For entrypoint CancelEscrow sent by admin (will fail -> unknown escrow)
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/cameligo/payment.mligo 'CancelEscrow("escrow2")'  '{admin=("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address); currencies=Map.literal[("TZBTC", ("KT1MdenM9nqSvRnoLinXwU6dKYkug6upkezM" : address))]; escrows=Map.literal[("escrow1", {currency="TZBTC"; amount=100n; buyer=("tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur" : address); seller=("tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF" : address); escrowContract=(None : address option); cancelled=false; released=false; paid=true})]; judges=(Map.empty : (nat, address) map); votingContract=("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)}' -e main --sender tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK
```

- For entrypoint ReleaseEscrow sent by admin (will fail -> escrow not paid by buyer)
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/cameligo/payment.mligo 'ReleaseEscrow("escrow1")'  '{admin=("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address); currencies=Map.literal[("TZBTC", ("KT1MdenM9nqSvRnoLinXwU6dKYkug6upkezM" : address))]; escrows=Map.literal[("escrow1", {currency="TZBTC"; amount=100n; buyer=("tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur" : address); seller=("tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF" : address); escrowContract=(None : address option); cancelled=false; released=false; paid=false})]; judges=(Map.empty : (nat, address) map); votingContract=("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)}' -e main --sender tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK
```

- For entrypoint ReleaseEscrow sent by admin (will fail -> unknown escrow)
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/cameligo/payment.mligo 'ReleaseEscrow("escrow2")'  '{admin=("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address); currencies=Map.literal[("TZBTC", ("KT1MdenM9nqSvRnoLinXwU6dKYkug6upkezM" : address))]; escrows=Map.literal[("escrow1", {currency="TZBTC"; amount=100n; buyer=("tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur" : address); seller=("tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF" : address); escrowContract=(None : address option); cancelled=false; released=false; paid=false})]; judges=(Map.empty : (nat, address) map); votingContract=("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)}' -e main --sender tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK
```

- For entrypoint ReleaseEscrow sent by seller (will fail -> no transfer entrypoint)
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/cameligo/payment.mligo 'ReleaseEscrow("escrow1")'  '{admin=("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address); currencies=Map.literal[("TZBTC", ("KT1MdenM9nqSvRnoLinXwU6dKYkug6upkezM" : address))]; escrows=Map.literal[("escrow1", {currency="TZBTC"; amount=100n; buyer=("tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur" : address); seller=("tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF" : address); escrowContract=(None : address option); cancelled=false; released=false; paid=true})]; judges=(Map.empty : (nat, address) map); votingContract=("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)}' -e main --sender tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF
```

### Test feployment (with ligo compiler)
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run test src/cameligo/payment.mligo
```