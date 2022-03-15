# Compile
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next run test bigarray/test/bigarray.test.mligo

# Launch tests
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile contract bigarray/cameligo/contract.mligo -e main > bigarray/compiled/bigArray.tz