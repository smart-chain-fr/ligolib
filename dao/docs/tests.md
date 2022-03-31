# Tests

## Usage

Run `make test`

## Code Style

- End-to-end tests and helpers should only import the contract under test "main" file,
  keeping this convention allows for easier refactoring.
- End-to-end tests are separated by entry points, this allows to bootstrap desired storage
  state specifically, and is lowering cognitive load when focusing on a test 
  (which usually only consists in calling only one entry point at a time).  
  As a result, each test file is named after the entry point under test: 
  `one_of_parameter.test.mligo`.
- Test environment is bootstrapped at the beginning of each end-to-end test, or test suite,
  because sharing environment between tests or test suites can lead to higher cognitive load.
- Names of the end-to-end tests functions follow a convention, they should either begin with 
  `test_success` when the test is expected to be successful or `test_failure` when the test is
  expected to return a `failwith` error.  
  Additionally, tested failures should be named after the tested error, 
  as an example: `test_failure_not_owner`.

## Development Tips

A way to have some TDD experience is to use [entr](https://github.com/eradman/entr) (or any other watcher)
and export a `SUITE` variable when calling `test` target, as an example:

```sh
fd -g "**/*.mligo" . | entr bash -c "SUITE=vote make test"
```

