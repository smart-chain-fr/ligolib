ligo_compiler=docker run --rm -v "$$PWD":"$$PWD" -w "$$PWD" ligolang/ligo:0.40.0
# ligo_compiler=../../../ligo
PROJECTROOT_OPT=--project-root .
PROTOCOL_OPT=--protocol ithaca
JSON_OPT=--michelson-format json

help:
	@echo  'Usage:'
	@echo  '  all             - Remove generated Michelson files, recompile smart contracts and lauch all tests'
	@echo  '  clean           - Remove generated Michelson files'
	@echo  '  compile         - Compiles smart contract Factory'
	@echo  '  test            - Run integration tests (written in Ligo)'
	@echo  '  deploy          - Deploy smart contracts advisor & indice (typescript using Taquito)'
	@echo  ''

all: clean compile test

compile: fa2_nft.tz factory marketplace_nft.tz

factory: factory.tz factory.json

factory.tz: contracts/main.mligo
	@echo "Compiling smart contract to Michelson"
	@$(ligo_compiler) compile contract $^ -e main $(PROTOCOL_OPT) $(PROJECTROOT_OPT) > compiled/$@

factory.json: contracts/main.mligo
	@echo "Compiling smart contract to Michelson in JSON format"
	@$(ligo_compiler) compile contract $^ $(JSON_OPT) -e main $(PROTOCOL_OPT) $(PROJECTROOT_OPT) > compiled/$@

fa2_nft.tz: contracts/generic_fa2/core/instance/NFT.mligo
	@echo "Compiling smart contract FA2 to Michelson"
	@$(ligo_compiler) compile contract $^ -e main $(PROTOCOL_OPT) $(PROJECTROOT_OPT) > contracts/generic_fa2/compiled/$@

marketplace_nft.tz: contracts/marketplace/main.mligo
	@echo "Compiling smart contract Marketplace to Michelson"
	@$(ligo_compiler) compile contract $^ -e main $(PROTOCOL_OPT) $(PROJECTROOT_OPT) > contracts/marketplace/compiled/$@

clean: clean_contracts clean_fa2 clean_marketplace

clean_contracts:
	@echo "Removing Michelson files"
	@rm -f compiled/*.tz compiled/*.json

clean_fa2:
	@echo "Removing FA2 Michelson file"
	@rm -f contracts/generic_fa2/compiled/*.tz

clean_marketplace:
	@echo "Removing Marketplace Michelson file"
	@rm -f contracts/marketplace/compiled/*.tz


test: test_ligo test_marketplace

test_ligo: test/test.mligo 
	@echo "Running integration tests"
	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT) $(PROJECTROOT_OPT)

test_marketplace: test/test_marketplace.mligo
	@echo "Running integration tests (marketplace)"
	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT) $(PROJECTROOT_OPT)

deploy: deploy_node_modules deploy.js
	@echo "Deploying contract"
	@node deploy/deploy.js

deploy.js: 
	@cd deploy && tsc deploy.ts --resolveJsonModule -esModuleInterop

deploy_node_modules:
	@echo "Install node modules"
	@cd deploy && npm install
