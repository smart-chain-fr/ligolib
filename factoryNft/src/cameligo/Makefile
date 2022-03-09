ligo_compiler=docker run --rm -v "$$PWD":"$$PWD" -w "$$PWD" ligolang/ligo:next
# ligo_compiler=../../../ligo
PROJECTROOT_OPT=--project-root .
PROTOCOL_OPT=--protocol hangzhou
JSON_OPT=--michelson-format json

help:
	@echo  'Usage:'
	@echo  '  all             - Remove generated Michelson files, recompile smart contracts and lauch all tests'
	@echo  '  clean           - Remove generated Michelson files'
	@echo  '  compile         - Compiles smart contract Factory'
	@echo  '  test            - Run integration tests (written in Ligo)'
	@echo  '  dry-run         - Simulate execution of entrypoints (with the Ligo compiler)'
	@echo  '  deploy          - Deploy smart contracts advisor & indice (typescript using Taquito)'
	@echo  ''

all: clean compile test

compile: factory fa2_nft

factory: factory.tz factory.json

factory.tz: contracts/main.mligo
	@echo "Compiling smart contract to Michelson"
	@$(ligo_compiler) compile contract $^ -e main $(PROTOCOL_OPT) $(PROJECTROOT_OPT) > compiled/$@

factory.json: contracts/main.mligo
	@echo "Compiling smart contract to Michelson in JSON format"
	@$(ligo_compiler) compile contract $^ $(JSON_OPT) -e main $(PROTOCOL_OPT) $(PROJECTROOT_OPT) > compiled/$@

fa2_nft: package.json
	@$(ligo_compiler) install tezos-ligo-fa2

clean:
	@echo "Removing Michelson files"
	@rm compiled/*.tz compiled/*.json

test: test_ligo

test_ligo: test/test.mligo 
	@echo "Running integration tests"
	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT) $(PROJECTROOT_OPT)

# test_ligo_2: test/test2.mligo 
# 	@echo "Running integration tests (fail)"
# 	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT)

deploy: deploy_node_modules deploy.js
	@echo "Deploying contract"
	@node deploy/deploy.js

deploy.js: 
	@cd deploy && tsc deploy.ts --resolveJsonModule -esModuleInterop

deploy_node_modules:
	@echo "Install node modules"
	@cd deploy && npm install
