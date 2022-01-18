ligo=docker run --rm -v "$$PWD":"$$PWD" -w "$$PWD" ligolang/ligo:next
protocol=--protocol hangzhou
json=--michelson-format json

all: compile test

help:
	@echo  'Usage:'
	@echo  '  all             - Remove generated Michelson files, recompile smart contracts and lauch all tests'
	@echo  '  clean           - Remove generated Michelson and JavaScript files'
	@echo  '  test            - Run integration tests (written in Ligo)'
	@echo  '  deploy          - Deploy smart contracts advisor & indice (typescript using Taquito)'
	@echo  ''

compile: main.jsligo clean
	@echo "Compiling to Michelson"
	@$(ligo) compile contract main.jsligo $(protocol) > Multisig.tz
	@echo "Compiling to Michelson json format"
	@$(ligo) compile contract main.jsligo $(json) $(protocol) > Multisig.json
	@echo "Compiling TypeScript in JavaScript"
	@tsc deployMultisig.ts --esModuleInterop --resolveJsonModule

clean:
	@echo "Removing Michelson files"
	@rm -rf *.tz
	@echo "Removing Michelson 'json format' files"
	@rm -rf *.json
	@echo "Removing TypeScript compiled files"
	@rm -rf *.js

test: tests/tests.jsligo
	@echo "Running the tests"
	@$(ligo) run test tests/tests.jsligo $(protocol)

originate:
	@echo "Deploying contract"
	@node deployMultisig.js