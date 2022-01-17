ligo_compiler=docker run --rm -v "$$PWD":"$$PWD" -w "$$PWD" ligolang/ligo:next
PROTOCOL_OPT=--protocol hangzhou
JSON_OPT=--michelson-format json

help:
	@echo  'Usage:'
	@echo  '  all             - Remove generated Michelson files, recompile smart contracts and lauch all tests'
	@echo  '  clean           - Remove generated Michelson files'
	@echo  '  advisor         - Compiles smart contract advisor'
	@echo  '  indice          - Compiles smart contract indice'
	@echo  '  test_ligo       - Run integration tests (written in Ligo)'
	@echo  '  test_pytezos    - Run unit tests (written in pytezos)'
	@echo  '  dry-run         - Simulate execution of entrypoints (with the Ligo compiler)'
	@echo  '  deploy          - Deploy smart contracts advisor & indice (typescript using Taquito)'
	@echo  ''

all: clean indice advisor test_ligo dry-run

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

deploy: node_modules deploy.js
	node deploy/deploy.js

deploy.js: 
	cd deploy && tsc deploy.ts --resolveJsonModule -esModuleInterop

node_modules:
	cd deploy && npm install

dry-run: dry-run_indice dry-run_advisor

dry-run_advisor: advisor.jsligo
#	@echo $(simulateline)
	$(ligo_compiler) compile parameter $^ 'ExecuteAlgorithm(unit)' -e advisorMain $(PROTOCOL_OPT)
	$(ligo_compiler) compile parameter $^ 'ChangeAlgorithm((l : list<int>) : bool => { return false })' -e advisorMain $(PROTOCOL_OPT)
	$(ligo_compiler) compile storage $^ '{indices:(list([{contractAddress:("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" as address), viewName:"indice_value"}, {contractAddress:("KT18zSbiHxK2Jzd9D71uPJBJ4iXoLyNseCeV" as address), viewName:"indice_value"}]) as list<indiceEntry>), algorithm:((l : list<int>) : bool => { return false }), result: false}' -e advisorMain $(PROTOCOL_OPT)	
	$(ligo_compiler) run dry-run $^  'ExecuteAlgorithm(unit)' '{indices:(list([{contractAddress:("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" as address), viewName:"indice_value"}, {contractAddress:("KT18zSbiHxK2Jzd9D71uPJBJ4iXoLyNseCeV" as address), viewName:"indice_value"}]) as list<indiceEntry>), algorithm:((l : list<int>) : bool => { return false }), result: false}' -e advisorMain $(PROTOCOL_OPT) 
	$(ligo_compiler) run dry-run $^  'ChangeAlgorithm( (l : list<int>) : bool => { return false })' '{indices:(list([{contractAddress:("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" as address), viewName:"indice_value"}, {contractAddress:("KT18zSbiHxK2Jzd9D71uPJBJ4iXoLyNseCeV" as address), viewName:"indice_value"}]) as list<indiceEntry>), algorithm:((l : list<int>) : bool => { return false }), result: false}' -e advisorMain $(PROTOCOL_OPT)
	$(ligo_compiler) run dry-run $^  'ChangeAlgorithm( (l : list<int>) : bool => { let mean = (l : list<int>) : int => { let compute = ( [accnb, elt] : [[int, nat], int] ) : [int, nat] => [(accnb[0] + elt as int), (accnb[1] + (1 as nat))]; let [sum, size] : [int, nat] = List.fold(compute, l, [(0 as int), (0 as nat)]); if (size == (0 as nat)) { return 0 } else { return (sum / size) }; }; return (mean(l) < 5)} )' '{indices:(list([{contractAddress:("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" as address), viewName:"indice_value"}, {contractAddress:("KT18zSbiHxK2Jzd9D71uPJBJ4iXoLyNseCeV" as address), viewName:"indice_value"}]) as list<indiceEntry>), algorithm:((l : list<int>) : bool => { return false }), result: false}' -e advisorMain $(PROTOCOL_OPT)


dry-run_indice: indice.jsligo
	$(ligo_compiler) compile parameter $^ 'Increment(5)' -e indiceMain $(PROTOCOL_OPT)
	$(ligo_compiler) compile parameter $^ 'Decrement(5)' -e indiceMain $(PROTOCOL_OPT)
	$(ligo_compiler) run dry-run $^  'Increment(5)' '37' -e indiceMain $(PROTOCOL_OPT)
	$(ligo_compiler) run dry-run $^  'Decrement(5)' '37' -e indiceMain $(PROTOCOL_OPT)