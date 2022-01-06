## Contract Indice

### Compile Indice contract 
- generates michelson code 
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile contract src/jsligo/indice.jsligo -e indiceMain > src/jsligo/compiled/indice.tz
```
- generates michelson code in JSON format
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile contract src/jsligo/indice.jsligo --michelson-format json -e indiceMain > src/jsligo/compiled/indice.json
```

### Compile Indice storage
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile storage src/jsligo/indice.jsligo '4' -e indiceMain
```

### Compile parameter (with ligo compiler) into Michelson expression

- For entrypoint SendValue
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile parameter src/jsligo/indice.jsligo 'SendValue(unit)' -e indiceMain
```
- For entrypoint Increment
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile parameter src/jsligo/indice.jsligo 'Increment(5)' -e indiceMain
```

### Simulate execution of entrypoints (with ligo compiler)

- For entrypoint SendValue (will fail)
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/jsligo/indice.jsligo  'SendValue(unit)' '37' -e indiceMain
```

- For entrypoint Increment
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/jsligo/indice.jsligo  'Increment(5)' '37' -e indiceMain
```

### Originate the Indice contract (with tezos-client CLI)
```
tezos-client originate contract indice transferring 1 from bootstrap1 running '/home/frank/ligo_tutorial_fundadvisor/src/jsligo/compiled/indice.tz' --init '0' --dry-run
```



## Contract Advisor

### Compile advisor contract 
- generates michelson code
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile contract src/jsligo/advisor.jsligo -e advisorMain > src/jsligo/compiled/advisor.tz
```
- generates michelson code in JSON format
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile contract src/jsligo/advisor.jsligo --michelson-format json -e advisorMain > src/jsligo/compiled/advisor.json
```

### Compile advisor storage

- With empty storage and trivial lambda function
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile storage src/jsligo/advisor.jsligo '{indiceAddress: ("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" as address), algorithm: (i : int) : bool => { return false }, result: false}' -e advisorMain
```

- With less trivial lambda function
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile storage src/jsligo/advisor.jsligo '{indiceAddress: ("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" as address), algorithm: (i : int) : bool => { if (i < 10) { return true } else { return false } }, result: false}' -e advisorMain
```

### Compile parameter (with ligo compiler) into Michelson expression

- For entrypoint ReceiveValue
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile parameter src/jsligo/advisor.jsligo 'ReceiveValue(5)' -e advisorMain
```
- For entrypoint RequestValue
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile parameter src/jsligo/advisor.jsligo 'RequestValue(unit)' -e advisorMain
```
- For entrypoint ChangeAlgorithm
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile parameter src/jsligo/advisor.jsligo 'ChangeAlgorithm((i : int) : bool => { return false })' -e advisorMain
```


### Simulate execution of entrypoints (with ligo compiler)

- For entrypoint ReceiveValue
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/jsligo/advisor.jsligo  'ReceiveValue(5)' '{indiceAddress: ("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" as address), algorithm: (i : int) : bool => { if (i < 10) { return true } else { return false } }, result: false}' -e advisorMain
```

- For entrypoint RequestValue
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/jsligo/advisor.jsligo  'RequestValue(unit)' '{indiceAddress: ("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" as address), algorithm: (i : int) : bool => { if (i < 10) { return true } else { return false } }, result: false}' -e advisorMain
```

- For entrypoint ChangeAlgorithm
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/jsligo/advisor.jsligo  'ChangeAlgorithm((i : int) : bool => { return false })' '{indiceAddress: ("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" as address), algorithm: (i : int) : bool => { if (i < 10) { return true } else { return false } }, result: false}' -e advisorMain
```

### Originate the Advisor contract with tezos-client CLI

#### Prepare initial storage 

- Compile the sotrage into Michelson expression
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile storage src/jsligo/advisor.jsligo '{indiceAddress: ("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" as address), algorithm: (i : int) : bool => { if (i < 10) { return true } else { return false } }, result: false}' -e advisorMain
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
tezos-client originate contract advisor transferring 1 from bootstrap1  running '/home/frank/ligo_tutorial_fundadvisor/src/jsligo/compiled/advisor.tz' --init '(Pair (Pair { PUSH int 10 ; SWAP ;COMPARE ;LT ;IF { PUSH bool True } { PUSH bool False } } "KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn") False)' --dry-run
```

- Verify the entrypoint is callable
```
tezos-client transfer 0 from bootstrap3 to advisor --arg '(Right Unit)' --dry-run
```