LIGO=docker run --platform linux/amd64 --rm -v "$(PWD)":"$(PWD)" -w "$(PWD)" ligolang/ligo:0.47.0
PROTOCOL_OPT=--protocol jakarta
JSON_OPT=--michelson-format json

help:
	@echo  'Usage:'
	@echo  '  all					- Removes Michelson files, recompile contracts and launch tests'
	@echo  '  clean					- Removes all generated Michelson files'
	@echo  '  compile				- Compiles all smart contracts'
	@echo  '  compile_oracle		- Compiles smart contract Oracle'
	@echo  '  compile_betting		- Compiles smart contract Betting'
	@echo  '  test					- Runs all integration tests in LIGO'
	@echo  '  test_oracle			- Runs integration tests for Oracle in LIGO'
	@echo  '  test_betting			- Runs integration tests for Betting in LIGO'
	@echo  '  deploy				- Deploys all smart contracts with Taquito'
	@echo  '  deploy_oracle			- Deploys smart contracts Oracle with Taquito'
	@echo  '  deploy_betting		- Deploys smart contracts Betting with Taquito'
	@echo  '  dry-run				- Simulates execution of all entrypoints in LIGO'
	@echo  ''

all: clean compile test

compile: compile_oracle compile_betting

compile_oracle: oracle.tz oracle.json

compile_betting: betting.tz betting.json

oracle.tz: contracts/cameligo/oracle/main.mligo
	@echo "Compiling Oracle smart contract to Michelson"
	@$(LIGO) compile contract $^ -e main $(PROTOCOL_OPT) --output-file compiled/$@

oracle.json: contracts/cameligo/oracle/main.mligo
	@echo "Compiling Oracle smart contract to Michelson in JSON format"
	@$(LIGO) compile contract $^ $(JSON_OPT) -e main $(PROTOCOL_OPT) --output-file compiled/$@

betting.tz: contracts/cameligo/betting/main.mligo
	@echo "Compiling Betting smart contract to Michelson"
	@$(LIGO) compile contract $^ -e main $(PROTOCOL_OPT) --output-file compiled/$@

betting.json: contracts/cameligo/betting/main.mligo
	@echo "Compiling Betting smart contract to Michelson in JSON format"
	@$(LIGO) compile contract $^ $(JSON_OPT) -e main $(PROTOCOL_OPT) --output-file compiled/$@

clean:
	@echo "Removing Michelson files"
	@rm compiled/*.tz compiled/*.json

test: test_oracle test_betting

test_oracle: test_oracle_manager test_oracle_signer test_oracle_pause test_oracle_events

test_oracle_manager: test/oracle/test.manager.mligo
	@echo "Running Oracle (ChangeManager) tests..." 
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

test_oracle_signer: test/oracle/test.signer.mligo
	@echo "Running Oracle (ChangeSigner) tests..." 
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

test_oracle_pause: test/oracle/test.pause.mligo
	@echo "Running Oracle (SwitchPause) tests..." 
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

test_oracle_events: test_oracle_event_add test_oracle_event_update test_oracle_event_get
	@echo "Running Oracle Events tests..."

test_oracle_event_add: test/oracle/test.eventAdd.mligo
	@echo "Running Oracle AddEvent tests..." 
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

test_oracle_event_update: test/oracle/test.eventUpdate.mligo
	@echo "Running Oracle UpdateEvent tests..." 
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

test_oracle_event_get: test/oracle/test.eventGet.mligo
	@echo "Running Oracle GetEvent tests..." 
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

test_betting: test_betting_manager test_betting_oracle test_betting_pause test_betting_events

test_betting_manager: test/betting/test.manager.mligo
	@echo "Running Betting (ChangeManager) tests..." 
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

test_betting_oracle: test/betting/test.oracle.mligo
	@echo "Running Betting (ChangeOracleAddress) tests..." 
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

test_betting_pause: test/betting/test.pause.mligo
	@echo "Running Betting (SwitchPause) tests..." 
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

test_betting_events: test_betting_event_add test_betting_event_update test_betting_event_get
	@echo "Running Betting Events tests..."

test_betting_event_add: test/betting/test.eventAdd.mligo
	@echo "Running betting AddEvent tests..." 
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

test_betting_event_update: test/betting/test.eventUpdate.mligo
	@echo "Running betting UpdateEvent tests..." 
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

test_betting_event_get: test/betting/test.eventGet.mligo
	@echo "Running betting GetEvent tests..." 
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

deploy: node_modules deploy_oracle deploy_betting
	@echo "Deploying contracts"
	
node_modules:
	@echo "Installing node modules"
	@cd deploy && npm install

deploy_oracle:
	@cd deploy && tsc deploy_oracle --resolveJsonModule -esModuleInterop
	@node deploy/deploy_oracle.js

deploy_betting:
	@cd deploy && tsc deploy_betting --resolveJsonModule -esModuleInterop
	@node deploy/deploy_betting.js

dry-run: dry-run_oracle dry-run_betting

dry-run_oracle: contracts/cameligo/oracle/main.mligo
	$(LIGO) compile parameter $^ 'ExecuteAlgorithm(unit)' -e oracleMain $(PROTOCOL_OPT)
	$(LIGO) compile parameter $^ 'ChangeAlgorithm(fun(i : int) -> False)' -e oracleMain $(PROTOCOL_OPT)
	$(LIGO) run dry-run $^  'ExecuteAlgorithm(unit)' '{bettingAddress=("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" : address); algorithm=(fun(i : int) -> if i < 10 then True else False); result=False}' -e oracleMain $(PROTOCOL_OPT) 
	$(LIGO) run dry-run $^  'ChangeAlgorithm(fun(i : int) -> False)' '{bettingAddress=("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" : address); algorithm=(fun(i : int) -> if i < 10 then True else False); result=False}' -e oracleMain $(PROTOCOL_OPT)

dry-run_betting: contracts/cameligo/betting/main.mligo
	$(LIGO) compile parameter $^ 'Increment(5)' -e bettingMain $(PROTOCOL_OPT)
	$(LIGO) compile parameter $^ 'Decrement(5)' -e bettingMain $(PROTOCOL_OPT)
	$(LIGO) run dry-run $^  'Increment(5)' '37' -e bettingMain $(PROTOCOL_OPT)
	$(LIGO) run dry-run $^  'Decrement(5)' '37' -e bettingMain $(PROTOCOL_OPT)