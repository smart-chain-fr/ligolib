LIGO=docker run --platform linux/amd64 --rm -v "$(PWD)":"$(PWD)" -w "$(PWD)" ligolang/ligo:0.50.0
PROTOCOL_OPT=--protocol jakarta
JSON_OPT=--michelson-format json

help:
	@echo  'Usage:'
	@echo  '  all				- Remove Michelson files, recompile contracts and launch tests'
	@echo  '  all-deploy			- Remove Michelson files, recompile contracts, launch tests and deploy contracts'
	@echo  '  clean				- Remove all generated Michelson files'
	@echo  ''
	@echo  '  compile			- Compile all smart contracts'
	@echo  '  compile_oracle		- Compile smart contract Oracle'
	@echo  '  compile_betting		- Compile smart contract Betting'
	@echo  ''
	@echo  '  test				- Run all integration tests in LIGO'
	@echo  '  test_oracle			- Run integration LIGO tests for Oracle'
	@echo  '  test_betting			- Run integration LIGO tests for Betting'
	@echo  ''
	@echo  '  deploy			- Deploy all smart contracts with Taquito'
	@echo  '  deploy_oracle			- Deploy smart contracts with Taquito for Oracle'
	@echo  '  deploy_betting		- Deploy smart contracts with Taquito for Betting'
	@echo  ''

all: clean compile test

all-deploy: clean compile test deploy

clean:
	@echo "Removing Michelson files..."
	@rm -f src/compiled/*.tz src/compiled/*.json
	@echo "Removing JS deploy files..."
	@rm -f src/deploy/*.js

# -------------------------
# 		LIGO SECTION
# -------------------------

compile: compile_callback_oracle compile_oracle compile_callback_betting compile_betting

compile_oracle: oracle.tz oracle.json

compile_betting: betting.tz betting.json

compile_callback_oracle: callback_oracle.tz callback_oracle.json

compile_callback_betting: callback_betting.tz callback_betting.json

oracle.tz: src/contracts/cameligo/oracle/main.mligo
	@echo "Compiling Oracle smart contract to Michelson..."
	@$(LIGO) compile contract $^ -e main $(PROTOCOL_OPT) --output-file src/compiled/$@

oracle.json: src/contracts/cameligo/oracle/main.mligo
	@echo "Compiling Oracle smart contract to Michelson in JSON format..."
	@$(LIGO) compile contract $^ $(JSON_OPT) -e main $(PROTOCOL_OPT) --output-file src/compiled/$@

betting.tz: src/contracts/cameligo/betting/main.mligo
	@echo "Compiling Betting smart contract to Michelson..."
	@$(LIGO) compile contract $^ -e main $(PROTOCOL_OPT) --output-file src/compiled/$@

betting.json: src/contracts/cameligo/betting/main.mligo
	@echo "Compiling Betting smart contract to Michelson in JSON format..."
	@$(LIGO) compile contract $^ $(JSON_OPT) -e main $(PROTOCOL_OPT) --output-file src/compiled/$@

callback_oracle.tz: src/contracts/cameligo/oracle/callback/main.mligo
	@echo "Compiling callback_Oracle smart contract to Michelson..."
	@$(LIGO) compile contract $^ -e main $(PROTOCOL_OPT) --output-file src/compiled/$@

callback_oracle.json: src/contracts/cameligo/oracle/callback/main.mligo
	@echo "Compiling callback_Oracle smart contract to Michelson in JSON format..."
	@$(LIGO) compile contract $^ $(JSON_OPT) -e main $(PROTOCOL_OPT) --output-file src/compiled/$@

callback_betting.tz: src/contracts/cameligo/betting/callback/main.mligo
	@echo "Compiling callback_Betting smart contract to Michelson..."
	@$(LIGO) compile contract $^ -e main $(PROTOCOL_OPT) --output-file src/compiled/$@

callback_betting.json: src/contracts/cameligo/betting/callback/main.mligo
	@echo "Compiling callback_Betting smart contract to Michelson in JSON format..."
	@$(LIGO) compile contract $^ $(JSON_OPT) -e main $(PROTOCOL_OPT) --output-file src/compiled/$@

# -------------------------
# 		TEST SECTION
# -------------------------

test: test_oracle test_betting

test_oracle: test_oracle_manager test_oracle_signer test_oracle_pause test_oracle_events

test_oracle_manager: src/test/oracle/test.manager.mligo
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

test_oracle_signer: src/test/oracle/test.signer.mligo
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

test_oracle_pause: src/test/oracle/test.pause.mligo
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

test_oracle_events: test_oracle_event_add test_oracle_event_update test_oracle_event_get

test_oracle_event_add: src/test/oracle/test.eventAdd.mligo
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

test_oracle_event_update: src/test/oracle/test.eventUpdate.mligo
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

test_oracle_event_get: src/test/oracle/test.eventGet.mligo
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

test_betting: test_betting_manager test_betting_oracle test_betting_pause test_betting_events test_betting_bet

test_betting_manager: src/test/betting/test.manager.mligo
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

test_betting_oracle: src/test/betting/test.oracle.mligo
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

test_betting_pause: src/test/betting/test.pause.mligo
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

test_betting_events: test_betting_event_add test_betting_event_update test_betting_event_get

test_betting_event_add: src/test/betting/test.eventAdd.mligo
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

test_betting_event_update: src/test/betting/test.eventUpdate.mligo
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

test_betting_event_get: src/test/betting/test.eventGet.mligo
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

test_betting_bet: test_betting_bet_add test_betting_bet_finalize

test_betting_bet_add: src/test/betting/test.betAdd.mligo
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

test_betting_bet_finalize: src/test/betting/test.betFinalize.mligo
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

# -------------------------
# 		DEPLOY SECTION
# -------------------------

deploy: node_modules deploy_oracle deploy_betting
	@echo "Deploying contracts..."

node_modules:
	@cd src/deploy && npm install

deploy_oracle:
	@cd src/deploy && tsc deploy_oracle --resolveJsonModule -esModuleInterop
	@node src/deploy/deploy_oracle.js

deploy_betting:
	@cd src/deploy && tsc deploy_betting --resolveJsonModule -esModuleInterop
	@node src/deploy/deploy_betting.js

deploy_callback_oracle:
	@cd src/deploy && tsc deploy_callback_oracle --resolveJsonModule -esModuleInterop
	@node src/deploy/deploy_callback_oracle.js

deploy_callback_betting:
	@cd src/deploy && tsc deploy_callback_betting --resolveJsonModule -esModuleInterop
	@node src/deploy/deploy_callback_betting.js

# -------------------------
#         FLEXTESA
# -------------------------

flextesa-start:
	@./src/deploy/run-flextesa.sh

flextesa-stop:
	@docker stop flextesa