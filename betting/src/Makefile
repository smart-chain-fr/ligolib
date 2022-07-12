LIGO=docker run --platform linux/amd64 --rm -v "$(PWD)":"$(PWD)" -w "$(PWD)" ligolang/ligo:0.45.0
PROTOCOL_OPT=--protocol jakarta
JSON_OPT=--michelson-format json

help:
	@echo  'Usage:'
	@echo  '  all					- Remove Michelson files, recompile contracts and launch tests'
	@echo  '  clean					- Remove generated Michelson files'
	@echo  '  compile				- Compiles smart contract Oracle and Betting'
	@echo  '  compile_oracle		- Compiles smart contract Oracle'
	@echo  '  compile_betting		- Compiles smart contract Betting'
	@echo  '  test					- Run integration tests in LIGO'
	@echo  '  dry-run				- Simulate execution of entrypoints in LIGO'
	@echo  '  deploy				- Deploy smart contracts Oracle & Betting with Taquito'
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

test_oracle_events: test/oracle/test.eventAdd.mligo test/oracle/test.eventUpdate.mligo test/oracle/test.eventGet.mligo
	@echo "Running Oracle Events tests..." 
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

test_betting: test_betting_manager test_betting_signer test_betting_pause

test_betting_manager: test/betting/test.manager.mligo
	@echo "Running Betting (ChangeManager) tests..." 
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

test_betting_signer: test/betting/test.signer.mligo
	@echo "Running Betting (ChangeSigner) tests..." 
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

test_betting_pause: test/betting/test.pause.mligo
	@echo "Running Betting (SwitchPause) tests..." 
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

deploy: node_modules deploy.js
	@echo "Deploying contracts"
	@node deploy/deploy.js

node_modules:
	@echo "Installing node modules"
	@cd deploy && npm install

deploy.js:
	@cd deploy && tsc deploy.ts --resolveJsonModule -esModuleInterop

dry-run: dry-run_oracle dry-run_betting

dry-run_oracle: oracle.mligo
	$(LIGO) compile parameter contracts/oracle/main.mligo 'ExecuteAlgorithm(unit)' -e oracleMain $(PROTOCOL_OPT)
	$(LIGO) compile parameter contracts/oracle/main.mligo 'ChangeAlgorithm(fun(i : int) -> False)' -e oracleMain $(PROTOCOL_OPT)
	$(LIGO) run dry-run contracts/oracle/main.mligo  'ExecuteAlgorithm(unit)' '{bettingAddress=("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" : address); algorithm=(fun(i : int) -> if i < 10 then True else False); result=False}' -e oracleMain $(PROTOCOL_OPT) 
	$(LIGO) run dry-run contracts/oracle/main.mligo  'ChangeAlgorithm(fun(i : int) -> False)' '{bettingAddress=("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" : address); algorithm=(fun(i : int) -> if i < 10 then True else False); result=False}' -e oracleMain $(PROTOCOL_OPT)

dry-run_betting: betting.mligo
	$(LIGO) compile parameter betting.mligo 'Increment(5)' -e bettingMain $(PROTOCOL_OPT)
	$(LIGO) compile parameter betting.mligo 'Decrement(5)' -e bettingMain $(PROTOCOL_OPT)
	$(LIGO) run dry-run betting.mligo  'Increment(5)' '37' -e bettingMain $(PROTOCOL_OPT)
	$(LIGO) run dry-run betting.mligo  'Decrement(5)' '37' -e bettingMain $(PROTOCOL_OPT)