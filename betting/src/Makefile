LIGO=docker run --platform linux/amd64 --rm -v "$(PWD)":"$(PWD)" -w "$(PWD)" ligolang/ligo:0.45.0
PROTOCOL_OPT=--protocol jakarta
JSON_OPT=--michelson-format json

help:
	@echo  'Usage:'
	@echo  '  all             - Remove generated Michelson files, recompile smart contracts and launch all tests'
	@echo  '  clean           - Remove generated Michelson files'
	@echo  '  compile         - Compiles smart contract oracle and betting'
	@echo  '  oracle          - Compiles smart contract oracle'
	@echo  '  betting         - Compiles smart contract betting'
	@echo  '  test            - Run integration tests (written in Ligo) and unit tests (written in pytezos)'
	@echo  '  dry-run         - Simulate execution of entrypoints (with the Ligo compiler)'
	@echo  '  deploy          - Deploy smart contracts oracle & betting (typescript using Taquito)'
	@echo  ''

all: clean compile test

compile: oracle betting

oracle: oracle.tz oracle.json

betting: betting.tz betting.json

oracle.tz: contracts/cameligo/oracle/main.mligo
	@echo "Compiling oracle smart contract to Michelson"
	@$(LIGO) compile contract $^ -e oracleMain $(PROTOCOL_OPT) > compiled/$@

oracle.json: contracts/cameligo/oracle/main.mligo
	@echo "Compiling oracle smart contract to Michelson in JSON format"
	@$(LIGO) compile contract $^ $(JSON_OPT) -e oracleMain $(PROTOCOL_OPT) > compiled/$@

betting.tz: contracts/cameligo/betting/main.mligo
	@echo "Compiling betting smart contract to Michelson"
	@$(LIGO) compile contract $^ -e bettingMain $(PROTOCOL_OPT) > compiled/$@

betting.json: contracts/cameligo/betting/main.mligo
	@echo "Compiling betting smart contract to Michelson in JSON format"
	@$(LIGO) compile contract $^ $(JSON_OPT) -e bettingMain $(PROTOCOL_OPT) > compiled/$@

clean:
	@echo "Removing Michelson files"
	@rm compiled/*.tz compiled/*.json

test: test_oracle test_betting

test_oracle: test/oracle/test.mligo
	@echo "Running allowance tests..." 
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

test_betting: test/betting/test.mligo
	@echo "Running integration tests"
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

deploy: node_modules deploy.js
	@echo "Deploying contracts"
	@node deploy/deploy.js

node_modules:
	@echo "Install node modules"
	@cd deploy && npm install

deploy.js: 
	@cd deploy && tsc deploy.ts --resolveJsonModule -esModuleInterop

dry-run: dry-run_betting dry-run_oracle

dry-run_betting: betting.mligo
	$(LIGO) compile parameter betting.mligo 'Increment(5)' -e bettingMain $(PROTOCOL_OPT)
	$(LIGO) compile parameter betting.mligo 'Decrement(5)' -e bettingMain $(PROTOCOL_OPT)
	$(LIGO) run dry-run betting.mligo  'Increment(5)' '37' -e bettingMain $(PROTOCOL_OPT)
	$(LIGO) run dry-run betting.mligo  'Decrement(5)' '37' -e bettingMain $(PROTOCOL_OPT)

dry-run_oracle: oracle.mligo
	$(LIGO) compile parameter contracts/oracle/main.mligo 'ExecuteAlgorithm(unit)' -e oracleMain $(PROTOCOL_OPT)
	$(LIGO) compile parameter contracts/oracle/main.mligo 'ChangeAlgorithm(fun(i : int) -> False)' -e oracleMain $(PROTOCOL_OPT)
	$(LIGO) run dry-run contracts/oracle/main.mligo  'ExecuteAlgorithm(unit)' '{bettingAddress=("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" : address); algorithm=(fun(i : int) -> if i < 10 then True else False); result=False}' -e oracleMain $(PROTOCOL_OPT) 
	$(LIGO) run dry-run contracts/oracle/main.mligo  'ChangeAlgorithm(fun(i : int) -> False)' '{bettingAddress=("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" : address); algorithm=(fun(i : int) -> if i < 10 then True else False); result=False}' -e oracleMain $(PROTOCOL_OPT)