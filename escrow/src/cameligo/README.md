## Contract Payment

### Compile Payment contract 
- generates michelson code 
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile contract src/cameligo/payment.mligo -e main > src/cameligo/compiled/payment.tz
```
- generates michelson code in JSON format
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile contract src/cameligo/payment.mligo --michelson-format json -e main > src/cameligo/compiled/payment.json
```

### Compile Payment storage
- with no currencies, no escrows, no judges
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile storage src/cameligo/payment.mligo '{admin=("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address); currencies=(Map.empty : (currency, address) map); escrows=(Big_map.empty : (escrowId, escrow) big_map); judges=(Map.empty : (nat, address) map); votingContract=("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)}' -e main
```

- with 1 escrow, 1 currencies, no judges
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile storage src/cameligo/payment.mligo '{admin=("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address); currencies=Map.literal[("TZBTC", ("KT1MdenM9nqSvRnoLinXwU6dKYkug6upkezM" : address))]; escrows=Big_map.literal[("escrow1", {currency="TZBTC"; amount=100n; buyer=("tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur" : address); seller=("tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF" : address); escrowContract=(None : address option); canceled=false; released=false; paid=false})]; judges=(Map.empty : (nat, address) map); votingContract=("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)}' -e main
```

 

### Compile parameter (with ligo compiler) into Michelson expression

- For entrypoint AddCurrency
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile parameter src/cameligo/payment.mligo 'AddCurrency("ETHTZ", ("KT1RmgE6SFgHFbKZDQsCCBz8jLvFyDd3z1su" : address))' -e main
```

- For entrypoint DeleteCurrency
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile parameter src/cameligo/payment.mligo 'DeleteCurrency("TZBTC")' -e main
```

- For entrypoint Pay
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile parameter src/cameligo/payment.mligo 'Pay({currency="TZBTC"; amount=100n; escrowId="escrow1"})' -e main
```

- For entrypoint CancelPayment
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile parameter src/cameligo/payment.mligo 'CancelPayment("escrow1")' -e main
```

- For entrypoint ReleasePayment
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile parameter src/cameligo/payment.mligo 'ReleasePayment("escrow1")' -e main
```

- For entrypoint SetEscrowcontract
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile parameter src/cameligo/payment.mligo 'SetEscrowcontract("escrow1", ("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi":address))' -e main
```

- For entrypoint SetAdmin
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile parameter src/cameligo/payment.mligo 'SetAdmin(("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK":address))' -e main
```


### Simulate execution of entrypoints (with ligo compiler)

- For entrypoint AddCurrency (will fail)
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/cameligo/payment.mligo  'AddCurrency("ETHTZ", ("KT1RmgE6SFgHFbKZDQsCCBz8jLvFyDd3z1su" : address))' '{admin=("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address); currencies=Map.literal[("TZBTC", ("KT1MdenM9nqSvRnoLinXwU6dKYkug6upkezM" : address))]; escrows=Big_map.literal[("escrow1", {currency="TZBTC"; amount=100n; buyer=("tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur" : address); seller=("tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF" : address); escrowContract=(None : address option); canceled=false; released=false; paid=false})]; judges=(Map.empty : (nat, address) map); votingContract=("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)}' -e main
```

- For entrypoint AddCurrency (sent with admin -> SUCCESS)
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/cameligo/payment.mligo  'AddCurrency("ETHTZ", ("KT1RmgE6SFgHFbKZDQsCCBz8jLvFyDd3z1su" : address))' '{admin=("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address); currencies=Map.literal[("TZBTC", ("KT1MdenM9nqSvRnoLinXwU6dKYkug6upkezM" : address))]; escrows=Big_map.literal[("escrow1", {currency="TZBTC"; amount=100n; buyer=("tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur" : address); seller=("tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF" : address); escrowContract=(None : address option); canceled=false; released=false; paid=false})]; judges=(Map.empty : (nat, address) map); votingContract=("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)}' -e main --sender tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK
```

- For entrypoint DeleteCurrency (will fail because not admin)
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/cameligo/payment.mligo  'DeleteCurrency("TZBTC")' '{admin=("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address); currencies=Map.literal[("TZBTC", ("KT1MdenM9nqSvRnoLinXwU6dKYkug6upkezM" : address))]; escrows=Big_map.literal[("escrow1", {currency="TZBTC"; amount=100n; buyer=("tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur" : address); seller=("tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF" : address); escrowContract=(None : address option); canceled=false; released=false; paid=false})]; judges=(Map.empty : (nat, address) map); votingContract=("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)}' -e main
```

- For entrypoint DeleteCurrency (will fail because currency_unknown)
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/cameligo/payment.mligo  'DeleteCurrency("ETHTZ")' '{admin=("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address); currencies=Map.literal[("TZBTC", ("KT1MdenM9nqSvRnoLinXwU6dKYkug6upkezM" : address))]; escrows=Big_map.literal[("escrow1", {currency="TZBTC"; amount=100n; buyer=("tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur" : address); seller=("tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF" : address); escrowContract=(None : address option); canceled=false; released=false; paid=false})]; judges=(Map.empty : (nat, address) map); votingContract=("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)}' -e main --sender tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK
```

- For entrypoint DeleteCurrency 
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/cameligo/payment.mligo  'DeleteCurrency("TZBTC")' '{admin=("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address); currencies=Map.literal[("TZBTC", ("KT1MdenM9nqSvRnoLinXwU6dKYkug6upkezM" : address))]; escrows=Big_map.literal[("escrow1", {currency="TZBTC"; amount=100n; buyer=("tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur" : address); seller=("tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF" : address); escrowContract=(None : address option); canceled=false; released=false; paid=false})]; judges=(Map.empty : (nat, address) map); votingContract=("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)}' -e main --sender tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK
```
=> risky because some escrow might get stuck (no more currency to transfer)

- For entrypoint Pay (will fail -> no entrypoint transfer)
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/cameligo/payment.mligo 'Pay({currency="TZBTC"; amount=100n; escrowId="escrow1"})'  '{admin=("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address); currencies=Map.literal[("TZBTC", ("KT1MdenM9nqSvRnoLinXwU6dKYkug6upkezM" : address))]; escrows=Big_map.literal[("escrow1", {currency="TZBTC"; amount=100n; buyer=("tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur" : address); seller=("tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF" : address); escrowContract=(None : address option); canceled=false; released=false; paid=false})]; judges=(Map.empty : (nat, address) map); votingContract=("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)}' -e main --sender tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur
```

- For entrypoint Pay (will fail -> sender is not buyer)
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/cameligo/payment.mligo 'Pay({currency="TZBTC"; amount=100n; escrowId="escrow1"})'  '{admin=("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address); currencies=Map.literal[("TZBTC", ("KT1MdenM9nqSvRnoLinXwU6dKYkug6upkezM" : address))]; escrows=Big_map.literal[("escrow1", {currency="TZBTC"; amount=100n; buyer=("tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur" : address); seller=("tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF" : address); escrowContract=(None : address option); canceled=false; released=false; paid=false})]; judges=(Map.empty : (nat, address) map); votingContract=("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)}' -e main --sender tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK
```

- For entrypoint Pay (will fail -> unknown_escrow)
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/cameligo/payment.mligo 'Pay({currency="TZBTC"; amount=100n; escrowId="escrow2"})'  '{admin=("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address); currencies=Map.literal[("TZBTC", ("KT1MdenM9nqSvRnoLinXwU6dKYkug6upkezM" : address))]; escrows=Big_map.literal[("escrow1", {currency="TZBTC"; amount=100n; buyer=("tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur" : address); seller=("tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF" : address); escrowContract=(None : address option); canceled=false; released=false; paid=false})]; judges=(Map.empty : (nat, address) map); votingContract=("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)}' -e main --sender tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur
```


- For entrypoint CancelPayment sent by admin (will fail -> escrow not paid by buyer)
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/cameligo/payment.mligo 'CancelPayment("escrow1")'  '{admin=("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address); currencies=Map.literal[("TZBTC", ("KT1MdenM9nqSvRnoLinXwU6dKYkug6upkezM" : address))]; escrows=Big_map.literal[("escrow1", {currency="TZBTC"; amount=100n; buyer=("tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur" : address); seller=("tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF" : address); escrowContract=(None : address option); canceled=false; released=false; paid=false})]; judges=(Map.empty : (nat, address) map); votingContract=("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)}' -e main --sender tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK
```

- For entrypoint CancelPayment sent by buyer (will fail -> should be sent by admin)
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/cameligo/payment.mligo 'CancelPayment("escrow1")'  '{admin=("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address); currencies=Map.literal[("TZBTC", ("KT1MdenM9nqSvRnoLinXwU6dKYkug6upkezM" : address))]; escrows=Big_map.literal[("escrow1", {currency="TZBTC"; amount=100n; buyer=("tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur" : address); seller=("tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF" : address); escrowContract=(None : address option); canceled=false; released=false; paid=false})]; judges=(Map.empty : (nat, address) map); votingContract=("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)}' -e main --sender tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur
```

- For entrypoint CancelPayment sent by admin (will fail -> no transfer entrypoint)
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/cameligo/payment.mligo 'CancelPayment("escrow1")'  '{admin=("tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK" : address); currencies=Map.literal[("TZBTC", ("KT1MdenM9nqSvRnoLinXwU6dKYkug6upkezM" : address))]; escrows=Big_map.literal[("escrow1", {currency="TZBTC"; amount=100n; buyer=("tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur" : address); seller=("tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF" : address); escrowContract=(None : address option); canceled=false; released=false; paid=true})]; judges=(Map.empty : (nat, address) map); votingContract=("KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" : address)}' -e main --sender tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK
```

