# Lambdas

This contract allows to associate lambdas with proposals.

## Makefile helper

A helper has been made to help pack lambdas expressions and generate hashes:

1. Create a file inside the [./lambdas](./lambdas) directory
2. Run `F=./lambdas/my-lambda.mligo make compile-lambda` to test it
3. Run `F=./lambdas/my-lambda.mligo make pack-lambda` to get packed and hash parameters
