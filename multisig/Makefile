ligo=docker run --rm -v "$$PWD":"$$PWD" -w "$$PWD" ligolang/ligo:next
protocol=--protocol hangzhou
json=--michelson-format json

all: clean compile test

help:
	@echo  'Usage:'
	@echo  '  all             - Remove generated Michelson files, recompile smart contracts, lauch all tests and originate contract'
	@echo  '  compile '
	@echo  '  clean           - Remove generated Michelson and JavaScript files'
	@echo  '  test            - Run Ligo tests'
	@echo  '  originate       - Deploy multisig smart contract (typescript using Taquito)'
	

compile: cameligo/contract.mligo jsligo/contract.jsligo
	@echo "Compiling to Michelson"
	@$(ligo) compile contract cameligo/contract.mligo $(protocol) > compiled/Multisig_mligo.tz
	@$(ligo) compile contract jsligo/contract.jsligo $(protocol) > compiled/Multisig_jsligo.tz
	@echo "Compiling to Michelson in JSON format"
	@$(ligo) compile contract cameligo/contract.mligo $(json) $(protocol) > compiled/Multisig_mligo.json
	@$(ligo) compile contract jsligo/contract.jsligo $(json) $(protocol) > compiled/Multisig_jsligo.json

compile_ml: cameligo/contract.mligo
	@echo "Compiling to Michelson"
	@$(ligo) compile contract cameligo/contract.mligo $(protocol) > compiled/Multisig_mligo.tz
	@echo "Compiling to Michelson in JSON format"
	@$(ligo) compile contract cameligo/contract.mligo $(json) $(protocol) > compiled/Multisig_mligo.json

compile_js: jsligo/contract.jsligo
	@echo "Compiling to Michelson"
	@$(ligo) compile contract jsligo/contract.jsligo $(protocol) > compiled/Multisig_jsligo.tz
	@echo "Compiling to Michelson in JSON format"
	@$(ligo) compile contract jsligo/contract.jsligo $(json) $(protocol) > compiled/Multisig_jsligo.json

clean:
	@echo "Removing Michelson files"
	@rm compiled/*.tz
	@echo "Removing Michelson 'json format' files"
	@rm compiled/*.json

test: tests/multisig.test.jsligo
	@echo "Running tests"
	@$(ligo) run test tests/multisig.test.jsligo $(protocol)
	@echo "Running mutation tests"
	@$(ligo) run test tests/multisig_mutation.test.jsligo $(protocol)

originate: origination/deployMultisig.ts compile
	@echo "Deploying contract"
	@tsc origination/deployMultisig.ts --esModuleInterop --resolveJsonModule
	@node origination/deployMultisig.js