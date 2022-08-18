SHELL := /bin/bash

ifndef LIGO
LIGO=docker run -u $(id -u):$(id -g) --rm -v "$(PWD)":"$(PWD)" -w "$(PWD)" ligolang/ligo:0.45.0
endif
# ^ use LIGO en var bin if configured, otherwise use docker

project_root=--project-root .
# ^ required when using packages

help:
	@grep -E '^[ a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

compile = $(LIGO) compile contract $(project_root) ./src/$(1) -o ./compiled/$(2) $(3)
# ^ compile contract to michelson or micheline

test = $(LIGO) run test $(project_root) ./test/$(1)
# ^ run given test file

compile: ## compile contracts
	@if [ ! -d ./compiled ]; then mkdir ./compiled ; fi
	@$(call compile,main.jsligo,taco_shop_token.tz)
	@$(call compile,main.mligo,taco_shop_token.json,--michelson-format json)

clean: ## clean up
	@rm -rf compiled

deploy: ## deploy
	@if [ ! -f ./scripts/metadata.json ]; then cp scripts/metadata.json.dist \
        scripts/metadata.json ; fi
	@npx ts-node ./scripts/deploy.ts

install: ## install dependencies
	@if [ ! -f ./.env ]; then cp .env.dist .env ; fi
	@$(LIGO) install
	@npm i

.PHONY: test
test: ## run tests (SUITE=propose make test)
ifndef SUITE
	@$(call test,permit.test.mligo)
	@$(call test,set_expiry.test.mligo)
	@$(call test,set_admin.test.mligo)
	@$(call test,transfer.test.mligo)
else
	@$(call test,$(SUITE).test.mligo)
endif

sandbox-start: ## start sandbox
	@./scripts/run-sandbox

sandbox-stop: ## stop sandbox
	@docker stop sandbox
