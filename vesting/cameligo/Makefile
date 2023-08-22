default: help

# Perl Colors, with fallback if tput command not available
GREEN  := $(shell command -v tput >/dev/null 2>&1 && tput -Txterm setaf 2 || echo "")
BLUE   := $(shell command -v tput >/dev/null 2>&1 && tput -Txterm setaf 4 || echo "")
WHITE  := $(shell command -v tput >/dev/null 2>&1 && tput -Txterm setaf 7 || echo "")
YELLOW := $(shell command -v tput >/dev/null 2>&1 && tput -Txterm setaf 3 || echo "")
RESET  := $(shell command -v tput >/dev/null 2>&1 && tput -Txterm sgr0 || echo "")


project_root=--project-root .


# Add help text after each target name starting with '\#\#'
# A category can be added with @category
HELP_FUN = \
    %help; \
    while(<>) { push @{$$help{$$2 // 'options'}}, [$$1, $$3] if /^([a-zA-Z\-]+)\s*:.*\#\#(?:@([a-zA-Z\-]+))?\s(.*)$$/ }; \
    print "usage: make [target]\n\n"; \
    for (sort keys %help) { \
    print "${WHITE}$$_:${RESET}\n"; \
    for (@{$$help{$$_}}) { \
    $$sep = " " x (32 - length $$_->[0]); \
    print "  ${YELLOW}$$_->[0]${RESET}$$sep${GREEN}$$_->[1]${RESET}\n"; \
    }; \
    print "\n"; }

help:
	@perl -e '$(HELP_FUN)' $(MAKEFILE_LIST)

#######################################
#              PROJECT                #
#######################################

all: install compile deploy ##@Project - Runs all the deployment chain from scratch

#######################################
#            CONTRACTS                #
#######################################
ifndef LIGO
LIGO=docker run --platform linux/amd64 --rm -v "$(PWD)":"$(PWD)" -w "$(PWD)" ligolang/ligo:0.70.1
endif

compile = $(LIGO) compile contract $(project_root) ./src/$(1) -o ./compiled/$(2) $(3)
# ^ Compile contracts to Michelson or Micheline

test-ligo = $(LIGO) run test $(project_root) ./test/ligo/$(1)
# ^ Run the given LIGO Test file

compile: ##@Contracts - Compile LIGO contracts
	@if [ ! -d ./compiled ]; then mkdir ./compiled ; fi
	@echo "Compiling contracts..."
	@$(call compile,main.mligo,vesting.tz)
	@$(call compile,main.mligo,vesting.json,--michelson-format json)

test-ligo: ##@Contracts - Run LIGO tests (make test-ligo SUITE=factory)
ifndef SUITE
	@$(call test-ligo,vesting.start.fa2.test.mligo)
	@$(call test-ligo,vesting.release.fa2.test.mligo)
	@$(call test-ligo,vesting.revoke.fa2.test.mligo)
	@$(call test-ligo,vesting.revokeaddress.fa2.test.mligo)
	@$(call test-ligo,vesting.start.fa1.test.mligo)
	@$(call test-ligo,vesting.revoke.fa1.test.mligo)
	@$(call test-ligo,vesting.release.fa1.test.mligo)
	@$(call test-ligo,vesting.revokeaddress.fa1.test.mligo)
else
	@$(call test-ligo,$(SUITE).test.mligo)
endif

test-integration: ##@Contracts - Run integration tests
	$(MAKE) deploy
	@npm --prefix run test

clean: ##@Contracts - Contracts clean up
	@echo "Are you sure you want to DELETE ALL COMPILED CONTRACT FILES from your Compiled folder ? [y/N]" && read ans && if [ $${ans:-'N'} = 'y' ]; then rm -rf compiled/* ; fi

#######################################
#            SCRIPTS                  #
#######################################
install: ##@Scripts - Install NPM dependencies
	@if [ ! -f ./.env ]; then cp .env.dist .env ; fi
	@npm --prefix ./scripts install
	@$(LIGO) install


deploy: ##@Scripts - Deploy contracts
	@if [ ! -f ./scripts/metadata.json ]; then cp scripts/metadata.json.dist \
        scripts/metadata.json ; fi
	@npx ts-node ./scripts/deploy.ts

#######################################
#            SANDBOX                  #
#######################################
sandbox-start: ##@Sandbox - Start Flextesa sandbox
	@./scripts/run-sandbox

sandbox-stop: ##@Sandbox - Stop Flextesa sandbox
	@docker stop sandbox
