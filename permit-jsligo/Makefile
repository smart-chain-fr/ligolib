SHELL := /bin/bash

ifndef LIGO
LIGO=docker run -u $(id -u):$(id -g) --rm -v "$(PWD)":"$(PWD)" -w "$(PWD)" ligolang/ligo:stable
endif
# ^ use LIGO en var bin if configured, otherwise use docker

project_root=--project-root .
# ^ required when using packages

help:
	@grep -E '^[ a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

compile = $(LIGO) compile contract $(project_root) ./src/$(1) -o ./compiled/$(2) $(3) --no-warn
# ^ compile contract to michelson or micheline

test = $(LIGO) run test $(project_root) ./test/$(1) --no-warn
# ^ run given test file

compile: ## compile contracts
	@if [ ! -d ./compiled ]; then mkdir ./compiled ; fi
	@$(call compile,main.jsligo,taco_shop_token.tz)
	@$(call compile,main.jsligo,taco_shop_token.json,--michelson-format json)

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
test: ## run tests (SUITE=permit make test)
ifndef SUITE
	@$(call test,permit.test.jsligo)
	@$(call test,set_expiry.test.jsligo)
	@$(call test,set_admin.test.jsligo)
	@$(call test,transfer.test.jsligo)
	@$(call test,create_token.test.jsligo)
	@$(call test,mint_token.test.jsligo)
	@$(call test,burn_token.test.jsligo)
else
	@$(call test,$(SUITE).test.mligo)
endif

lint: ## lint code
	@npx eslint ./scripts --ext .ts

sandbox-start: ## start sandbox
	@./scripts/run-sandbox

sandbox-stop: ## stop sandbox
	@docker stop sandbox
