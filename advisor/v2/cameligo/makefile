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

all: clean indice advisor test_ligo

indice: indice.tz indice.json

advisor: advisor.tz advisor.json

indice.tz: indice.mligo
	$(ligo_compiler) compile contract $^ -e indiceMain $(PROTOCOL_OPT) > compiled/$@

indice.json: indice.mligo
	$(ligo_compiler) compile contract $^ $(JSON_OPT) -e indiceMain $(PROTOCOL_OPT) > compiled/$@

advisor.tz: advisor.mligo
	$(ligo_compiler) compile contract $^ -e advisorMain $(PROTOCOL_OPT) > compiled/$@

advisor.json: advisor.mligo
	$(ligo_compiler) compile contract $^ $(JSON_OPT) -e advisorMain $(PROTOCOL_OPT) > compiled/$@

clean:
	rm compiled/*.tz compiled/*.json

test_ligo: test/ligo/test.mligo
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

dry-run_advisor: advisor.mligo
#	@echo $(simulateline)
	$(ligo_compiler) compile parameter advisor.mligo 'ExecuteAlgorithm(unit)' -e advisorMain $(PROTOCOL_OPT)
	$(ligo_compiler) compile parameter advisor.mligo 'ChangeAlgorithm(fun(l : int list) -> False)' -e advisorMain $(PROTOCOL_OPT)
	$(ligo_compiler) run dry-run advisor.mligo  'ExecuteAlgorithm(unit)' '{indices=[{contractAddress=("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" : address); viewName="indice_value"}; {contractAddress=("KT18zSbiHxK2Jzd9D71uPJBJ4iXoLyNseCeV" : address); viewName="indice_value"}]; algorithm=(fun(l : int list) -> let i : int = match List.head_opt l with | None -> (failwith("missing value") : int) | Some(v) -> v in if i < 10 then True else False); result=False}' -e advisorMain $(PROTOCOL_OPT) 
	$(ligo_compiler) run dry-run advisor.mligo  'ChangeAlgorithm(fun(l : int list) -> False)' '{indices=[{contractAddress=("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" : address); viewName="indice_value"}; {contractAddress=("KT18zSbiHxK2Jzd9D71uPJBJ4iXoLyNseCeV" : address); viewName="indice_value"}]; algorithm=(fun(l : int list) -> let i : int = match List.head_opt l with | None -> (failwith("missing value") : int) | Some(v) -> v in if i < 10 then True else False); result=False}' -e advisorMain $(PROTOCOL_OPT)
	$(ligo_compiler) run dry-run advisor.mligo  'ChangeAlgorithm(fun(l : int list) -> let i : int = match List.head_opt l with | None -> (failwith("missing value") : int) | Some(v) -> v in if i < 3 then True else False)' '{indices=[{contractAddress=("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" : address); viewName="indice_value"}; {contractAddress=("KT18zSbiHxK2Jzd9D71uPJBJ4iXoLyNseCeV" : address); viewName="indice_value"}]; algorithm=(fun(l : int list) -> let i : int = match List.head_opt l with | None -> (failwith("missing value") : int) | Some(v) -> v in if i < 10 then True else False); result=False}' -e advisorMain $(PROTOCOL_OPT)
	$(ligo_compiler) run dry-run advisor.mligo  'ChangeAlgorithm(fun(l : int list) -> let _check : bool = match List.head_opt l with | None -> (failwith("empty list") : bool) | Some (_v) -> True in let (sum, size) : int * nat = List.fold (fun((acc, nb), elt : (int * nat) * int) : (int * nat) -> (acc + elt, nb + 1n)) l (0, 0n) in let mean : int = sum / size in if mean < 5 then True else False)' '{indices=[{contractAddress=("KT1D99kSAsGuLNmT1CAZWx51vgvJpzSQuoZn" : address); viewName="indice_value"}; {contractAddress=("KT18zSbiHxK2Jzd9D71uPJBJ4iXoLyNseCeV" : address); viewName="indice_value"}]; algorithm=(fun(l : int list) -> let i : int = match List.head_opt l with | None -> (failwith("missing value") : int) | Some(v) -> v in if i < 10 then True else False); result=False}' -e advisorMain $(PROTOCOL_OPT)


dry-run_indice: indice.mligo
	$(ligo_compiler) compile parameter indice.mligo 'Increment(5)' -e indiceMain $(PROTOCOL_OPT)
	$(ligo_compiler) compile parameter indice.mligo 'Decrement(5)' -e indiceMain $(PROTOCOL_OPT)
	$(ligo_compiler) run dry-run indice.mligo  'Increment(5)' '37' -e indiceMain $(PROTOCOL_OPT)
	$(ligo_compiler) run dry-run indice.mligo  'Decrement(5)' '37' -e indiceMain $(PROTOCOL_OPT)