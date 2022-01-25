ligo=docker run --rm -v "$$PWD":"$$PWD" -w "$$PWD" ligolang/ligo:next
protocol=--protocol hangzhou
json=--michelson-format json

all: compile test originate

help:
	@echo  'Usage:'
	@echo  '  all             - Remove generated Michelson files, recompile smart contracts, lauch all tests and originate contract'
	@echo  '  compile '
	@echo  '  clean           - Remove generated Michelson and JavaScript files'
	@echo  '  test            - Run Ligo tests'
	@echo  '  originate       - Deploy multisig smart contract (typescript using Taquito)'
	

compile: main.jsligo clean
	@echo "Compiling to Michelson"
	@$(ligo) compile contract main.jsligo $(protocol) > Multisig.tz
	@echo "Compiling to Michelson in JSON format"
	@$(ligo) compile contract main.jsligo $(json) $(protocol) > Multisig.json

clean:
	@echo "Removing Michelson files"
	@rm -rf *.tz
	@echo "Removing Michelson 'json format' files"
	@rm Multisig.json

test: tests/tests.jsligo
	@echo "Running tests"
	@$(ligo) run test tests/tests.jsligo $(protocol)

originate: compile
	@echo "Deploying contract"
	@tsc deployMultisig.ts --esModuleInterop --resolveJsonModule
	@node deployMultisig.js