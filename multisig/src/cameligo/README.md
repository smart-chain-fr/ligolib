## Contract multisig

### Compile multisig contract 
- generates michelson code 
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.33.0 compile contract src/cameligo/multisig.mligo -e multisigMain > src/cameligo/compiled/multisig.tz
```
- generates michelson code in JSON format
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.33.0 compile contract src/cameligo/multisig.mligo --michelson-format json -e multisigMain > src/cameligo/compiled/multisig.json
```

### Compile multisig storage
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.33.0 compile storage src/cameligo/multisig.mligo '4' -e multisigMain
```

### Run tests 
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.33.0 run test src/cameligo/test_ligo/test.mligo --protocol hangzhou
```
