SHELL := /bin/bash

ligo_compiler?=docker run --rm -v "$(PWD)":"$(PWD)" -w "$(PWD)" ligolang/ligo:next

project_root?=--project-root .
# ^ required when using packages

protocol_opt?=
# ^ fill-in to test new features, see "Protocol Upgrades" section
# on https://ligolang.org documentation

help:
	@grep -E '^[ a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

compile = $(ligo_compiler) compile contract $(project_root) ./src/$(1) -o ./compiled/$(2) $(3) $(protocol_opt)
# ^ compile contract to michelson or micheline

test = $(ligo_compiler) run test $(project_root) ./test/$(1) $(protocol_opt)
# ^ run given test file

compile: ## compile contracts
	@if [ ! -d ./compiled ]; then mkdir ./compiled ; fi
	@$(call compile,ticketer.mligo,ticketer.tz)
	@$(call compile,ticketer.mligo,ticketer.json,--michelson-format json)

clean: ## clean up
	@rm -rf compiled

deploy: ## deploy
	@if [ ! -f ./scripts/metadata.json ]; then cp scripts/metadata.json.dist \
        scripts/metadata.json ; fi
	@npx ts-node ./scripts/deploy.ts

install: ## install dependencies
	@if [ ! -f ./.env ]; then cp .env.dist .env ; fi
	@$(ligo_compiler) install
	@npm i

.PHONY: test
test: ## run tests (SUITE=buy_ticket make test)
ifndef SUITE
	@$(call test,buy_ticket.test.mligo)
else
	@$(call test,$(SUITE).test.mligo)
endif

lint: ## lint code
	@npx eslint ./scripts --ext .ts

sandbox-start: ## start sandbox
	@./scripts/run-sandbox

sandbox-stop: ## stop sandbox
	@docker stop sandbox
