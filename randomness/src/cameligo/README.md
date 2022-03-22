## Contract randomness

This smart contract implements an on-chain random number generator. The number generation is based on a random seed and a pseudo-random generator algorithm. In order to have an unbiased seed, users must perform a "Commit & Reveal" mechanism which is perfomed into two separated phases.

First users choose a secret number and send a proof  to the contract. Once all proofs are received users can reveal their secret numbers (and verify the committed proof). In the end all secret numbers are gathered and used to compute a hash (merckle tree), this hash is the random seed and can be converted into a nat. 

A Mercenne twister algorithm can be applied in order to generate random number with a satisfying distribution.
A modulus can be applied on the generated number to provide a random number on a specific range.

This smart contract intends to demonstrate the random number generation. The (`min`, `max`) range is specified in the storage at origination, and the result is stored in the `result_nat` field of the storage.

### Compilation of randomness contract

A makefile is provided to compile the "Randomness" smart contract, and to launch tests.
```
cd src/cameligo/
make compile
make test
```

### Tests

A makefile is provided to launch tests.
```
cd src/cameligo/
make test
```

### Deployment

A typescript script for deployment is provided to originate the smart contrat. This deployment script relies on .env file which provides the RPC node url and the deployer public and private key.

```
cd src/cameligo
make deploy
```


### Manual compilation/testing CLI 
- generates michelson code
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile contract src/cameligo/main.mligo -e main --protocol hangzhou > src/cameligo/compiled/randomness.tz
```

- generates michelson code in JSON format
```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile contract src/cameligo/main.mligo --michelson-format json -e main --protocol hangzhou > src/cameligo/compiled/shifumi.tz
```

- run test

```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next run test src/cameligo/main.mligo --protocol hangzhou
```

```
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next run dry-run src/cameligo/main.mligo 'Reveal(0xafa7bdbfe1ab82fdda918bbb8ef396c4ce9389c29e8e99cb8cd18ec2a1b1f98888809af8c4d09993eafe949396bf86c0bcffed93be96f8888ef3c39bf2e3bbc6e8c183dbd6a5ebe3b7abe9bec1fab6c9e8e3a390c780a2e1b0c4fe9db7a4f283caa9d182e6ffa8b5ede1acb1eefaaab3c1a3f3b58adf91e3efbeae98e0a8b3b6d1c0dcbfdde4dd9abda886acfdf1ce838bc5fecba8a6cf83a688edecc1f8a5b5cde6cbc6c485fbf6d0a7f7b3afd293e7ac8183c1e7a6f6d7fdf297daf7b5bea48182c2e8b0cfac89dbbf8ed1fef5abf3e0bbe7bbaaf2d8f7cdad99acb3d5efa6d1bfa5ad8cd6e5dbf983cee8f7959185e2cacc928fbfa3a6d2e3879fbdc0a6cbddb8b1fac6d399d9ceb0b5e0d790fd9a9ba3c0f7d8aba6a59bc0d4c987d8f8a887a9801701 , 0x9b8fe4a0e1ceb187e9b58cd08fccc0b0fce5f99880c8e3e8f9868ae5d1cfb8ae8c93ce828e9edea8f2fde1e8878bc7e291fd919fcac99ca6baa7b5ecc7f481a1d7d088c9c4fac4869bd086eea4d2dc8e86e4c8cbf3a696f2f99d81b7dbf0dc9bcfecf6ebb68ca9879295fd82eee2bcbdaffa92e5f0b7f5f1a3b2a2f5b0ceb3e2b89fe18685cbb1eea58290a5a1c2818de6e89b85939cbd81e6ffbb90fcd0c180c6cdd3b3d68b8ac0c1d394f0c0a694a4b4b7b8cf98d5a7f9a3c29f8684f8b98babe7b0a4c6a5efabebd2b6d2e4eb9181d18fbb81ffb4bfe7bafd94d9b4a9c69baaadf2cac9b6cef0dac8ac98d3f0c5f7cfb4f3f4f8f0bf97ac83b3b2f596f9a0b886ed90a9fca9e6dbe2f9fb8ebfe395e8f9d6f0a988e28bc6c3a7e6c591d8a7a582cf5989a69aede5c9c984d6e2928580fedadcf3c89695b89fbecea4caaceec5b783a9fec095e7b995fa96f09996bebcf8dde6f3d0e7cc82dad1c7ea9c8b8ec5ebfaa1ecc8eff780e381d0edf1ecc2bbbff890b3edd5e9c9b39fd1b2fcf3f3c5ecc285b6c7c9c4bbc7bed1b8e5838ea0aca1f0f59796c2d5b7838eb79feac8dcc894b1fee18285a2d698d5b2b081a0bfad9297e8f6c4d5e2f091ae968c8bdef7b0b0d8d1fcd8f2a2b283cab6cd9accb5aaf7ab9ee8e0d0c4b4c5d39ce6f6bd85a6b3dceee89dab91b5c6dcd484b1f09ef38797e7e2ab8289b7dfdba2e98edcb986b5ef84aaf886d48fa8a3eee5bdadc8ffdb9dcbc5fed7b7b4e585b48288e7c8f6b2c58a9382c295e3a4cfcdfae283ebcca88aefdbd9c0a89ed3de858dbc9ebf96e5bed28ec5a30188e868c9ec99407e14fa8c369f7d27c9fd430cd86f35e53300000011f4e2ef0ef42d774eda900cf984605ae10a , 10n)' '{ values=(Map.empty: (address, bytes) map); result=(None : address option) }' --protocol hangzhou
```