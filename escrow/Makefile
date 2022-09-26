LIGO=docker run --platform linux/amd64 --rm -v "$(PWD)":"$(PWD)" -w "$(PWD)" ligolang/ligo:0.51.0
PROTOCOL_OPT=--protocol kathmandu
JSON_OPT=--michelson-format json

help:
	@echo  'Usage:'
	@echo  '  all				- Remove Michelson files, recompile contracts and launch tests'
	@echo  ''
	@echo  '  clean				- Remove all generated Michelson files'
	@echo  ''
	@echo  '  compile			- Compile all smart contracts'
	@echo  ''
	@echo  '  test				- Run all integration tests in LIGO'
	@echo  ''
	@echo  '  deploy			- Deploy all smart contracts with Taquito'
	@echo  ''

all: clean compile test deploy

clean:
	@echo "Removing Michelson files..."
	@rm -f contracts/cameligo/compiled/*.tz contracts/cameligo/compiled/*.json
	@rm -f contracts/cameligo/instance/compiled/*.tz contracts/cameligo/instance/compiled/*.json
	@echo "Removing JS deploy files..."
	@rm -f deploy/*.js

# -------------------------
# 		LIGO SECTION
# -------------------------

compile: clean compile_escrow compile_factory

compile_escrow: escrow.tz escrow.json

escrow.tz: contracts/cameligo/instance/escrow.mligo
	@echo "Compiling escrow smart contract to Michelson..."
	@$(LIGO) compile contract $^ -e main $(PROTOCOL_OPT) --output-file contracts/cameligo/instance/compiled/$@

escrow.json: contracts/cameligo/instance/escrow.mligo
	@echo "Compiling escrow smart contract to Michelson in JSON format..."
	@$(LIGO) compile contract $^ $(JSON_OPT) -e main $(PROTOCOL_OPT) --output-file contracts/cameligo/instance/compiled/$@

compile_factory: factory.tz factory.json

factory.tz: contracts/cameligo/main.mligo
	@echo "Compiling factory smart contract to Michelson..."
	@$(LIGO) compile contract $^ -e main $(PROTOCOL_OPT) --output-file contracts/cameligo/compiled/$@

factory.json: contracts/cameligo/main.mligo
	@echo "Compiling factory smart contract to Michelson in JSON format..."
	@$(LIGO) compile contract $^ $(JSON_OPT) -e main $(PROTOCOL_OPT) --output-file contracts/cameligo/compiled/$@

# -------------------------
# 		TEST SECTION
# -------------------------

test: test_escrow

test_escrow: test_escrow_manager

test_escrow_manager: test/cameligo/test.mligo
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

# -------------------------
# 		DEPLOY SECTION
# -------------------------

deploy: deploy_escrow
	@echo "Deploying contracts..."

install:
	@cd deploy && npm install

deploy_escrow:
	@cd deploy && tsc deploy --resolveJsonModule -esModuleInterop
	@node deploy/deploy.js

# -------------------------
#         FLEXTESA
# -------------------------

flextesa-start:
	@./deploy/run-flextesa.sh

flextesa-stop:
	@docker stop flextesa