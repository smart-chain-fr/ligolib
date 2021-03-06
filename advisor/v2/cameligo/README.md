## Contract Indice

### Compile Indice contract 
- generates michelson code 
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile contract v2/cameligo/indice.mligo -e indiceMain --protocol hangzhou > v2/cameligo/compiled/indice.tz
```
- generates michelson code in JSON format
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile contract v2/cameligo/indice.mligo --michelson-format json -e indiceMain --protocol hangzhou > v2/cameligo/compiled/indice.json
```

### Compile Indice storage
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile storage v2/cameligo/indice.mligo '4' -e indiceMain --protocol hangzhou
```

### Compile parameter (with ligo compiler) into Michelson expression

- For entrypoint Increment
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile parameter v2/cameligo/indice.mligo 'Increment(5)' -e indiceMain --protocol hangzhou
```
- For entrypoint Decrement
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile parameter v2/cameligo/indice.mligo 'Decrement(5)' -e indiceMain --protocol hangzhou
```


### Simulate execution of entrypoints (with ligo compiler)

- For entrypoint Increment
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next run dry-run v2/cameligo/indice.mligo  'Increment(5)' '37' -e indiceMain --protocol hangzhou
```

- For entrypoint Decrement
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next run dry-run v2/cameligo/indice.mligo  'Decrement(5)' '37' -e indiceMain --protocol hangzhou
```

### Unit test pytezos
```
cd v2/cameligo/test/pytezos
python3 -m unittest test_indice.py -v
```

### Originate the Indice contract (with tezos-client CLI)
```
tezos-client originate contract indice transferring 1 from bootstrap1 running '/home/frank/ligo_tutorial_fundadvisor/src/cameligo/compiled/indice.tz' --init '0' --dry-run
```



## Contract Advisor

### Compile advisor contract 
- generates michelson code
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile contract v2/cameligo/advisor.mligo -e advisorMain --protocol hangzhou > v2/cameligo/compiled/advisor.tz
```

- generates michelson code in JSON format
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile contract v2/cameligo/advisor.mligo --michelson-format json -e advisorMain --protocol hangzhou > v2/cameligo/compiled/advisor.json
```

### Compile advisor storage

- With empty storage and trivial lambda function
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile storage v2/cameligo/advisor.mligo '{indices=[{contractAddress=("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" : address); viewName="indice_value"}; {contractAddress=("KT18zSbiHxK2Jzd9D71uPJBJ4iXoLyNseCeV" : address); viewName="indice_value"}]; algorithm=(fun(l : int list) -> False); result=False}' -e advisorMain --protocol hangzhou
```

- With less trivial lambda function
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile storage v2/cameligo/advisor.mligo '{indices=[{contractAddress=("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" : address); viewName="indice_value"}; {contractAddress=("KT18zSbiHxK2Jzd9D71uPJBJ4iXoLyNseCeV" : address); viewName="indice_value"}]; algorithm=(fun(l : int list) -> let i : int = match List.head_opt l with | None -> (failwith("missing value") : int) | Some(v) -> v in if i < 10 then True else False); result=False}' -e advisorMain --protocol hangzhou
```

### Compile parameter (with ligo compiler) into Michelson expression

- For entrypoint ExecuteAlgorithm
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile parameter v2/cameligo/advisor.mligo 'ExecuteAlgorithm(unit)' -e advisorMain --protocol hangzhou
```

- For entrypoint ChangeAlgorithm
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile parameter v2/cameligo/advisor.mligo 'ChangeAlgorithm(fun(i : int) -> False)' -e advisorMain --protocol hangzhou
```


### Simulate execution of entrypoints (with ligo compiler)

- For entrypoint ExecuteAlgorithm (will fail)
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next run dry-run v2/cameligo/advisor.mligo  'ExecuteAlgorithm(unit)' '{indices=[{contractAddress=("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" : address); viewName="indice_value"}; {contractAddress=("KT18zSbiHxK2Jzd9D71uPJBJ4iXoLyNseCeV" : address); viewName="indice_value"}]; algorithm=(fun(l : int list) -> let i : int = match List.head_opt l with | None -> (failwith("missing value") : int) | Some(v) -> v in if i < 10 then True else False); result=False}' -e advisorMain --protocol hangzhou
```

- For entrypoint ChangeAlgorithm
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next run dry-run v2/cameligo/advisor.mligo  'ChangeAlgorithm(fun(i : int) -> False)' '{indices=[{contractAddress=("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" : address); viewName="indice_value"}; {contractAddress=("KT18zSbiHxK2Jzd9D71uPJBJ4iXoLyNseCeV" : address); viewName="indice_value"}]; algorithm=(fun(l : int list) -> let i : int = match List.head_opt l with | None -> (failwith("missing value") : int) | Some(v) -> v in if i < 10 then True else False); result=False}' -e advisorMain --protocol hangzhou
```



### Originate the Advisor contract with tezos-client CLI

#### Prepare initial storage 

- Compile the sotrage into Michelson expression
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile storage v2/cameligo/advisor.mligo '{indices=[{contractAddress=("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" : address); viewName="indice_value"}; {contractAddress=("KT18zSbiHxK2Jzd9D71uPJBJ4iXoLyNseCeV" : address); viewName="indice_value"}]; algorithm=(fun(l : int list) -> let i : int = match List.head_opt l with | None -> (failwith("missing value") : int) | Some(v) -> v in if i < 10 then True else False); result=False}' -e advisorMain --protocol hangzhou
```

This command produces the following Michelson storage:
```
(Pair (Pair { PUSH int 10 ;
              SWAP ;
              COMPARE ;
              LT ;
              IF { PUSH bool True } { PUSH bool False } }
            "KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn")
      False)
```

- Deploy Advisor contract (with a sandbox)

```
tezos-client originate contract advisor transferring 1 from bootstrap1  running '/home/frank/Marigold/advisor/v2/cameligo/compiled/advisor.tz' --init '(Pair (Pair { PUSH int 10 ; SWAP ;COMPARE ;LT ;IF { PUSH bool True } { PUSH bool False } } "KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn") False)' --dry-run
```

- Verify the entrypoint is callable
```
tezos-client transfer 0 from bootstrap3 to advisor --arg '(Right Unit)' --dry-run
```

### Unit test pytezos
```
cd v2/cameligo/test/pytezos
python3 -m unittest test_advisor.py -v
```

### Test deployment/interact (with ligo compiler)
```
cd v2/cameligo
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next run test test/ligo/test.mligo --protocol hangzhou
```

### Deploy (with Taquito)
```
tsc deploy.ts --resolveJsonModule -esModuleInterop
```
```
node deploy.js
```