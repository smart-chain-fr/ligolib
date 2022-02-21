## Contract Shifumi

### Compile Shifumi contract 
- generates michelson code
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile contract src/cameligo/main.mligo -e shifumiMain --protocol hangzhou > src/cameligo/compiled/shifumi.tz
```

- generates michelson code in JSON format
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile contract src/cameligo/main.mligo --michelson-format json -e shifumiMain --protocol hangzhou > src/cameligo/compiled/shifumi.tz
```

- run tests
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next run test src/cameligo/test.mligo  --protocol hangzhou
```
