## Contract Indice

### Compile Indice contract 
- generates michelson code 
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile contract v2/jsligo/indice.jsligo -e indiceMain --protocol hangzhou > v2/jsligo/compiled/indice.tz
```
- generates michelson code in JSON format
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile contract v2/jsligo/indice.jsligo --michelson-format json -e indiceMain --protocol hangzhou > v2/jsligo/compiled/indice.json
```

### Compile Indice storage
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile storage v2/jsligo/indice.jsligo '4' -e indiceMain --protocol hangzhou
```

### Compile parameter (with ligo compiler) into Michelson expression

- For entrypoint Increment
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile parameter v2/jsligo/indice.jsligo 'Increment(5)' -e indiceMain --protocol hangzhou
```
- For entrypoint Decrement
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile parameter v2/jsligo/indice.jsligo 'Decrement(5)' -e indiceMain --protocol hangzhou
```


### Simulate execution of entrypoints (with ligo compiler)

- For entrypoint Increment
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next run dry-run v2/jsligo/indice.jsligo  'Increment(5)' '37' -e indiceMain --protocol hangzhou
```

- For entrypoint Decrement
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next run dry-run v2/jsligo/indice.jsligo  'Decrement(5)' '37' -e indiceMain --protocol hangzhou
```

### Originate the Indice contract (with tezos-client CLI)
```
tezos-client originate contract indice transferring 1 from bootstrap1 running '/home/frank/Marigold/advisor/v2/jsligo/compiled/indice.tz' --init '0' --dry-run
```


### Unit test pytezos
```
cd v2/jsligo/test/pytezos
python3 -m unittest test_indice.py -v
```


## Contract Advisor

### Compile advisor contract 
- generates michelson code
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile contract v2/jsligo/advisor.jsligo -e advisorMain --protocol hangzhou > v2/jsligo/compiled/advisor.tz
```
- generates michelson code in JSON format
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile contract v2/jsligo/advisor.jsligo --michelson-format json -e advisorMain --protocol hangzhou > v2/jsligo/compiled/advisor.json
```

### Compile advisor storage

- With empty storage and trivial lambda function
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile storage v2/jsligo/advisor.jsligo '{indices:(list([{contractAddress:("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" as address), viewName:"indice_value"}, {contractAddress:("KT18zSbiHxK2Jzd9D71uPJBJ4iXoLyNseCeV" as address), viewName:"indice_value"}]) as list<indiceEntry>), algorithm:((l : list<int>) : bool => { return false }), result: false}' -e advisorMain --protocol hangzhou
```

### Compile parameter (with ligo compiler) into Michelson expression

- For entrypoint ChangeAlgorithm
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile parameter v2/jsligo/advisor.jsligo 'ChangeAlgorithm((l : list<int>) : bool => { return false })' -e advisorMain --protocol hangzhou
```

- For entrypoint ExecuteAlgorithm
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile parameter v2/jsligo/advisor.jsligo 'ExecuteAlgorithm(unit)' -e advisorMain --protocol hangzhou
```

### Simulate execution of entrypoints (with ligo compiler)

- For entrypoint ChangeAlgorithm
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next run dry-run v2/jsligo/advisor.jsligo  'ChangeAlgorithm( (l : list<int>) : bool => { let mean = (l : list<int>) : int => { let compute = ( [accnb, elt] : [[int, nat], int] ) : [int, nat] => [(accnb[0] + elt as int), (accnb[1] + (1 as nat))]; let [sum, size] : [int, nat] = List.fold(compute, l, [(0 as int), (0 as nat)]); if (size == (0 as nat)) { return 0 } else { return (sum / size) }; }; return (mean(l) < 5)} )' '{indices:(list([{contractAddress:("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" as address), viewName:"indice_value"}, {contractAddress:("KT18zSbiHxK2Jzd9D71uPJBJ4iXoLyNseCeV" as address), viewName:"indice_value"}]) as list<indiceEntry>), algorithm:((l : list<int>) : bool => { return false }), result: false}' -e advisorMain --protocol hangzhou
```

- For entrypoint ExecuteAlgorithm (fails due to on-chain views)
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next run dry-run v2/jsligo/advisor.jsligo 'ExecuteAlgorithm(unit)' '{indices:(list([{contractAddress:("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" as address), viewName:"indice_value"}, {contractAddress:("KT18zSbiHxK2Jzd9D71uPJBJ4iXoLyNseCeV" as address), viewName:"indice_value"}]) as list<indiceEntry>), algorithm:((l : list<int>) : bool => { return false }), result: false}' -e advisorMain --protocol hangzhou
```

### Originate the Advisor contract with tezos-client CLI

#### Prepare initial storage 

- Compile the sotrage into Michelson expression
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile storage v2/jsligo/advisor.jsligo '{indices:(list([{contractAddress:("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" as address), viewName:"indice_value"}, {contractAddress:("KT18zSbiHxK2Jzd9D71uPJBJ4iXoLyNseCeV" as address), viewName:"indice_value"}]) as list<indiceEntry>), algorithm:((l : list<int>) : bool => { return false }), result: false}' -e advisorMain --protocol hangzhou
```

This command produces the following Michelson storage:
```
(Pair (Pair { DROP ; PUSH bool False }
            { Pair "KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" "indice_value" ;
              Pair "KT18zSbiHxK2Jzd9D71uPJBJ4iXoLyNseCeV" "indice_value" })
      False)
```

- Deploy Advisor contract (with a sandbox)

```
tezos-client originate contract advisor transferring 1 from bootstrap1  running '/home/frank/Marigold/advisor/v2/jsligo/compiled/advisor.tz' --init '(Pair (Pair { DROP ; PUSH bool False } { Pair "KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" "indice_value" ; Pair "KT18zSbiHxK2Jzd9D71uPJBJ4iXoLyNseCeV" "indice_value" }) False)' --dry-run
```

- Verify the entrypoint is callable
```
tezos-client transfer 0 from bootstrap3 to advisor --arg '(Right Unit)' --dry-run
```

### Test deployment/interact (with ligo compiler)
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next run test v2/jsligo/test/ligo/test.jsligo --protocol hangzhou
```


### Unit test pytezos
```
cd v2/jsligo/test/pytezos
python3 -m unittest test_advisor.py -v
```

### Deploy (with Taquito)
```
tsc deploy.ts --resolveJsonModule -esModuleInterop
node deploy.js
```