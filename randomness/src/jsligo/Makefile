ligo_compiler=docker run --rm -v "$$PWD":"$$PWD" -w "$$PWD" ligolang/ligo:next
# ligo_compiler=../../../ligo
PROJECTROOT_OPT=--project-root .
PROTOCOL_OPT=--protocol hangzhou
JSON_OPT=--michelson-format json

help:
	@echo  'Usage:'
	@echo  '  all             - Remove generated Michelson files, recompile smart contracts and lauch all tests'
	@echo  '  clean           - Remove generated Michelson files'
	@echo  '  compile         - Compiles smart contract Random'
	@echo  '  test            - Run integration tests (written in Ligo)'
	@echo  '  deploy          - Deploy smart contracts advisor & indice (typescript using Taquito)'
	@echo  ''

all: clean compile test

compile: random

random: random.tz random.json

random.tz: contracts/main.jsligo
	@echo "Compiling smart contract to Michelson"
	@$(ligo_compiler) compile contract $^ -e main $(PROTOCOL_OPT) $(PROJECTROOT_OPT) > compiled/$@

random.json: contracts/main.jsligo
	@echo "Compiling smart contract to Michelson in JSON format"
	@$(ligo_compiler) compile contract $^ $(JSON_OPT) -e main $(PROTOCOL_OPT) $(PROJECTROOT_OPT) > compiled/$@

clean:
	@echo "Removing Michelson files"
	@rm compiled/*.tz compiled/*.json

test: test_ligo test_ligo_bytes

test_ligo: test/test.jsligo 
	@echo "Running integration tests"
	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT)

test_ligo_bytes: test/test_bytes.jsligo 
	@echo "Running integration tests (bytes conversion)"
	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT)

deploy: node_modules deploy.js
	@echo "Deploying contract"
	@node deploy/deploy.js

deploy.js: 
	@cd deploy && tsc deploy.ts --resolveJsonModule -esModuleInterop

node_modules:
	@echo "Install node modules"
	@cd deploy && npm install
