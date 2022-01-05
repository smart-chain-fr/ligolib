## Contract Indice

### Compile Indice contract 
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile contract src/pascaligo/indice.ligo -e indiceMain > src/pascaligo/compiled/indice.tz
```

### Compile Indice storage
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile storage src/pascaligo/indice.ligo '4' -e indiceMain
```

### Compile parameter (with ligo compiler) into Michelson expression

- For entrypoint SendValue
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile parameter src/pascaligo/indice.ligo 'SendValue(unit)' -e indiceMain
```
- For entrypoint Increment
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile parameter src/pascaligo/indice.ligo 'Increment(5)' -e indiceMain
```

### Simulate execution of entrypoints (with ligo compiler)

- For entrypoint SendValue (will fail)
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/pascaligo/indice.ligo  'SendValue(unit)' '37' -e indiceMain
```

- For entrypoint Increment
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/pascaligo/indice.ligo  'Increment(5)' '37' -e indiceMain
```

### Originate the Indice contract (with tezos-client CLI)
```
tezos-client originate contract indice transferring 1 from bootstrap1 running '/home/frank/ligo_tutorial_fundadvisor/src/pascaligo/compiled/indice.tz' --init '0' --dry-run
```



## Contract Advisor

### Compile advisor contract 
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile contract src/pascaligo/advisor.ligo -e advisorMain > src/pascaligo/compiled/advisor.tz
```

### Compile advisor storage

- With empty storage and trivial lambda function
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile storage src/pascaligo/advisor.ligo 'record[indiceAddress=("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" : address); algorithm=(function(const i : int) is False); result=False]' -e advisorMain
```

- With less trivial lambda function
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile storage src/pascaligo/advisor.ligo 'record[indiceAddress=("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" : address); algorithm=(function(const i : int) is if i < 10 then True else False); result=False]' -e advisorMain
```

### Compile parameter (with ligo compiler) into Michelson expression

- For entrypoint ReceiveValue
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile parameter src/pascaligo/advisor.ligo 'ReceiveValue(5)' -e advisorMain
```
- For entrypoint RequestValue
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile parameter src/pascaligo/advisor.ligo 'RequestValue(unit)' -e advisorMain
```
- For entrypoint ChangeAlgorithm
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile parameter src/pascaligo/advisor.ligo 'ChangeAlgorithm(function(const i : int) is False)' -e advisorMain
```


### Simulate execution of entrypoints (with ligo compiler)

- For entrypoint ReceiveValue
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/pascaligo/advisor.ligo  'ReceiveValue(5)' 'record[indiceAddress=("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" : address); algorithm=(function(const i : int) is if i < 10 then True else False); result=False]' -e advisorMain
```

- For entrypoint RequestValue
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/pascaligo/advisor.ligo  'RequestValue(unit)' 'record[indiceAddress=("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" : address); algorithm=(function(const i : int) is if i < 10 then True else False); result=False]' -e advisorMain
```

- For entrypoint ChangeAlgorithm
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 run dry-run src/pascaligo/advisor.ligo  'ChangeAlgorithm(function(const i : int) is False)' 'record[indiceAddress=("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" : address); algorithm=(function(const i : int) is if i < 10 then True else False); result=False]' -e advisorMain
```

### Originate the Advisor contract with tezos-client CLI

#### Prepare initial storage 

- Compile the sotrage into Michelson expression
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.30.0 compile storage src/pascaligo/advisor.ligo 'record[indiceAddress=("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" : address); algorithm=(function(const i : int) is if i < 10 then True else False); result=False]' -e advisorMain
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
tezos-client originate contract advisor transferring 1 from bootstrap1  running '/home/frank/ligo_tutorial_fundadvisor/src/pascaligo/compiled/advisor.tz' --init '(Pair (Pair { PUSH int 10 ; SWAP ;COMPARE ;LT ;IF { PUSH bool True } { PUSH bool False } } "KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn") False)' --dry-run
```

- Verify the entrypoint is callable
```
tezos-client transfer 0 from bootstrap3 to advisor --arg '(Right Unit)' --dry-run
```