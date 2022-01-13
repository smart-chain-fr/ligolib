ligo_compiler=docker run --rm -v "$$PWD":"$$PWD" -w "$$PWD" ligolang/ligo:next
PROTOCOL_OPT=--protocol hangzhou
JSON_OPT=--michelson-format json

all: clean indice advisor test_ligo test_pytezos

indice: indice.tz indice.json

advisor: advisor.tz advisor.json

indice.tz: indice.jsligo
	$(ligo_compiler) compile contract $^ -e indiceMain $(PROTOCOL_OPT) > compiled/$@

indice.json: indice.jsligo
	$(ligo_compiler) compile contract $^ $(JSON_OPT) -e indiceMain $(PROTOCOL_OPT) > compiled/$@

advisor.tz: advisor.jsligo
	$(ligo_compiler) compile contract $^ -e advisorMain $(PROTOCOL_OPT) > compiled/$@

advisor.json: advisor.jsligo
	$(ligo_compiler) compile contract $^ $(JSON_OPT) -e advisorMain $(PROTOCOL_OPT) > compiled/$@

clean:
	rm compiled/*.tz compiled/*.json

test_ligo: test/ligo/test.jsligo
#	@echo $(CURDIR)
	$(ligo_compiler) run test $^ $(PROTOCOL_OPT)

test_pytezos: test_pytezos_sandbox test_pytezos_indice test_pytezos_advisor 

test_pytezos_indice: 
	cd $(CURDIR)/test/pytezos/ && python3 -m unittest test_indice.py -v
test_pytezos_advisor: 
	cd $(CURDIR)/test/pytezos/ && python3 -m unittest test_advisor.py -v
test_pytezos_sandbox: 
	cd $(CURDIR)/test/pytezos/ && python3 -m unittest test_sandbox.py -v

deploy: deploy.js
	node deploy/deploy.js

deploy.js: 
	cd deploy && tsc deploy.ts --resolveJsonModule -esModuleInterop


dry-run: dry-run_indice dry-run_advisor

dry-run_advisor: advisor.jsligo
#	@echo $(simulateline)
	$(ligo_compiler) compile parameter $^ 'ExecuteAlgorithm(unit)' -e advisorMain $(PROTOCOL_OPT)
	$(ligo_compiler) compile parameter $^ 'ChangeAlgorithm((i : int) : bool => { return false })' -e advisorMain $(PROTOCOL_OPT)
	$(ligo_compiler) run dry-run $^  'ExecuteAlgorithm(unit)' '{indiceAddress: ("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" as address), algorithm: (i : int) : bool => { if (i < 10) { return true } else { return false } }, result: false}' -e advisorMain $(PROTOCOL_OPT) 
	$(ligo_compiler) run dry-run $^  'ChangeAlgorithm((i : int) : bool => { return false })' '{indiceAddress: ("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" as address), algorithm: (i : int) : bool => { if (i < 10) { return true } else { return false } }, result: false}' -e advisorMain $(PROTOCOL_OPT)

dry-run_indice: indice.jsligo
	$(ligo_compiler) compile parameter $^ 'Increment(5)' -e indiceMain $(PROTOCOL_OPT)
	$(ligo_compiler) compile parameter $^ 'Decrement(5)' -e indiceMain $(PROTOCOL_OPT)
	$(ligo_compiler) run dry-run $^  'Increment(5)' '37' -e indiceMain $(PROTOCOL_OPT)
	$(ligo_compiler) run dry-run $^  'Decrement(5)' '37' -e indiceMain $(PROTOCOL_OPT)