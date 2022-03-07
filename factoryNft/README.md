## Contract factory NFT

### Compile factory contract 
- generates michelson code
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile contract src/cameligo/main.mligo -e main --protocol hangzhou > src/cameligo/compiled/factory.tz
```

- generates michelson code in JSON format
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile contract src/cameligo/main.mligo --michelson-format json -e main --protocol hangzhou > src/cameligo/compiled/factory.json
```

- run tests
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next run test src/cameligo/test.mligo  --protocol hangzhou
```
