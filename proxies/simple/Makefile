SHELL := /bin/bash

LIGO=@ligo
ifeq (, $(shell which ligo))
	LIGO=@docker run -v "$(PWD):$(PWD)" -w "$(PWD)" --rm -i ligolang/ligo:next 
endif

help:
	@grep -E '^[ a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

compile = $(LIGO) compile contract ./src/$(1) -o ./compiled/$(2) $(3)
test = $(LIGO) run test ./test/$(1)

.PHONY: test
test: ## run tests
	# 
	# featurev1
	$(call test,common/featurev1.test.mligo)

	#
	# featurev2
	$(call test,common/featurev2.test.mligo)

	#
	# proxy cameligo
	$(call test,cameligo/proxy.test.mligo)

	#
	# proxy cameligo mutation
	$(call test,cameligo/e2e_mutation.test.mligo)

	#
	# proxy jsligo
	$(call test,jsligo/proxy.test.jsligo)

	#
	# proxy jsligo
	$(call test,jsligo/e2e_mutation.test.jsligo)

compile: ## compile contracts
	@if [ ! -d ./compiled ]; then mkdir -p \
		./compiled/cameligo/basic \
		./compiled/common \
		./compiled/jsligo/basic \
	; fi

	# common
	$(call compile,common/featurev1.mligo,common/featurev1.tz)
	$(call compile,common/featurev1.mligo,common/featurev1.json,--michelson-format json)
	$(call compile,common/featurev1.mligo,common/featurev2.tz)
	$(call compile,common/featurev2.mligo,common/featurev2.json,--michelson-format json)
	
	# cameligo
	$(call compile,cameligo/proxy.mligo,cameligo/proxy.tz)
	$(call compile,cameligo/proxy.mligo,cameligo/proxy.json,--michelson-format json)
	
	# jsligo
	$(call compile,jsligo/proxy.jsligo,jsligo/proxy.tz)
	$(call compile,jsligo/proxy.jsligo,jsligo/proxy.json,--michelson-format json)

clean: ## clean up
	@rm -rf compiled

install: ## install
	npm i

deploy: ## deploy
	npx ts-node deploy.ts 
