LIGO=docker run --platform linux/amd64 --rm -v "$(PWD)":"$(PWD)" -w "$(PWD)" ligolang/ligo:0.43.0
PROTOCOL_OPT=--protocol ithaca
JSON_OPT=--michelson-format json

help:
	@echo  'Usage:'
	@echo  '  all             - Remove generated Michelson files, recompile smart contracts and lauch all tests'
	@echo  '  clean           - Remove generated Michelson files'
	@echo  '  compile         - Compiles smart contract advisor and indice'
	@echo  '  advisor         - Compiles smart contract advisor'
	@echo  '  indice          - Compiles smart contract indice'
	@echo  '  test            - Run integration tests (written in Ligo) and unit tests (written in pytezos)'
	@echo  '  test_ligo       - Run integration tests (written in Ligo)'
	@echo  '  test_pytezos    - Run unit tests (written in pytezos)'
	@echo  '  dry-run         - Simulate execution of entrypoints (with the Ligo compiler)'
	@echo  '  deploy          - Deploy smart contracts advisor & indice (typescript using Taquito)'
	@echo  ''

all: clean compile test

compile: indice advisor

indice: indice.tz indice.json

advisor: advisor.tz advisor.json

indice.tz: contracts/indice/main.mligo
	@echo "Compiling Indice smart contract to Michelson"
	@$(LIGO) compile contract $^ -e indiceMain $(PROTOCOL_OPT) > compiled/$@

indice.json: contracts/indice/main.mligo
	@echo "Compiling Indice smart contract to Michelson in JSON format"
	@$(LIGO) compile contract $^ $(JSON_OPT) -e indiceMain $(PROTOCOL_OPT) > compiled/$@

advisor.tz: contracts/advisor/main.mligo
	@echo "Compiling Advisor smart contract to Michelson"
	@$(LIGO) compile contract $^ -e advisorMain $(PROTOCOL_OPT) > compiled/$@

advisor.json: contracts/advisor/main.mligo
	@echo "Compiling Advisor smart contract to Michelson in JSON format"
	@$(LIGO) compile contract $^ $(JSON_OPT) -e advisorMain $(PROTOCOL_OPT) > compiled/$@

clean:
	@echo "Removing Michelson files"
	@rm compiled/*.tz compiled/*.json

test: test_ligo test_ligo_2 test_pytezos

test_ligo: test/ligo/test.mligo 
	@echo "Running integration tests"
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

test_ligo_2: test/ligo/test2.mligo 
	@echo "Running integration tests (fail)"
	@$(LIGO) run test $^ $(PROTOCOL_OPT)

test_pytezos: test_pytezos_sandbox test_pytezos_indice test_pytezos_advisor 

test_pytezos_indice: 
	@echo "Running unit tests (in pytezos) for Indice smart contract"
	@cd $(CURDIR)/test/pytezos/ && python3 -m unittest test_indice.py -v
test_pytezos_advisor: 
	@echo "Running unit tests (in pytezos) for Advisor smart contract"
	@cd $(CURDIR)/test/pytezos/ && python3 -m unittest test_advisor.py -v
test_pytezos_sandbox: 
	@echo "Running integration tests (in pytezos)"
	@cd $(CURDIR)/test/pytezos/ && python3 -m unittest test_sandbox.py -v

deploy: node_modules deploy.js
	@echo "Deploying contracts"
	@node deploy/deploy.js

deploy.js: 
	@cd deploy && tsc deploy.ts --resolveJsonModule -esModuleInterop

node_modules:
	@echo "Install node modules"
	@cd deploy && npm install

dry-run: dry-run_indice dry-run_advisor

dry-run_advisor: advisor.mligo
#	@echo $(simulateline)
	$(LIGO) compile parameter contracts/advisor/main.mligo 'ExecuteAlgorithm(unit)' -e advisorMain $(PROTOCOL_OPT)
	$(LIGO) compile parameter contracts/advisor/main.mligo 'ChangeAlgorithm(fun(i : int) -> False)' -e advisorMain $(PROTOCOL_OPT)
	$(LIGO) run dry-run contracts/advisor/main.mligo  'ExecuteAlgorithm(unit)' '{indiceAddress=("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" : address); algorithm=(fun(i : int) -> if i < 10 then True else False); result=False}' -e advisorMain $(PROTOCOL_OPT) 
	$(LIGO) run dry-run contracts/advisor/main.mligo  'ChangeAlgorithm(fun(i : int) -> False)' '{indiceAddress=("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" : address); algorithm=(fun(i : int) -> if i < 10 then True else False); result=False}' -e advisorMain $(PROTOCOL_OPT)

dry-run_indice: indice.mligo
	$(LIGO) compile parameter indice.mligo 'Increment(5)' -e indiceMain $(PROTOCOL_OPT)
	$(LIGO) compile parameter indice.mligo 'Decrement(5)' -e indiceMain $(PROTOCOL_OPT)
	$(LIGO) run dry-run indice.mligo  'Increment(5)' '37' -e indiceMain $(PROTOCOL_OPT)
	$(LIGO) run dry-run indice.mligo  'Decrement(5)' '37' -e indiceMain $(PROTOCOL_OPT)