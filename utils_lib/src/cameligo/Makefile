ligo_compiler=docker run --rm -v "$$PWD":"$$PWD" -w "$$PWD" ligolang/ligo:next

PROTOCOL_OPT=--protocol ithaca
JSON_OPT=--michelson-format json

help:
	@echo  'Usage:'
	@echo  '  all             - Remove generated Michelson files, recompile smart contracts and lauch all tests'
	@echo  '  test            - Run integration tests (written in Ligo)'
	@echo  ''

all: test

test: test_ligo_utils test_ligo_math_rational test_ligo_rational test_ligo_float test_ligo_math_float

test_ligo_utils: test/test_utils.mligo 
	@echo "Running integration tests (is_implicit, bytes_to_nat)"
	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT)

test_ligo_math_rational: test/test_math_rational.mligo 
	@echo "Running integration tests (Math)"
	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT)

test_ligo_rational: test/test_rational.mligo 
	@echo "Running integration tests (Rational)"
	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT)

test_ligo_float: test/test_float.mligo 
	@echo "Running integration tests (Float)"
	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT)

test_ligo_math_float: test/test_math_float.mligo 
	@echo "Running integration tests (Math)"
	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT)