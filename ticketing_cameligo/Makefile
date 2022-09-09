default: help

# Perl Colors, with fallback if tput command not available
GREEN  := $(shell command -v tput >/dev/null 2>&1 && tput -Txterm setaf 2 || echo "")
BLUE   := $(shell command -v tput >/dev/null 2>&1 && tput -Txterm setaf 4 || echo "")
WHITE  := $(shell command -v tput >/dev/null 2>&1 && tput -Txterm setaf 7 || echo "")
YELLOW := $(shell command -v tput >/dev/null 2>&1 && tput -Txterm setaf 3 || echo "")
RESET  := $(shell command -v tput >/dev/null 2>&1 && tput -Txterm sgr0 || echo "")

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

# nuke-all: ##@Project - Deletes IMPORTANT FILES & FOLDERS to reset to initial state
# 	@echo "Are you sure you want to UNPIN ALL FILES from your Pinata Cloud account ? [y/N]" && read ans && if [ $${ans:-'N'} = 'y' ]; then npx ts-node ./scripts/unpin; fi
# 	@echo "Are you sure you want to DELETE IMPORTANT FILES from this folder to RESET EVERYTHING to initial state ? [y/N]" && read ans && if [ $${ans:-'N'} = 'y' ]; then rm -rf node_modules/ assets/* compiled/* deployments/* ; fi

#######################################
#            CONTRACTS                #
#######################################
ifndef LIGO
LIGO=docker run --platform linux/amd64 --rm -v "$(PWD)":"$(PWD)" -w "$(PWD)" ligolang/ligo:0.49.0
endif

compile = $(LIGO) compile contract ./src/$(1) -o ./compiled/$(2) $(3)
# ^ Compile contracts to Michelson or Micheline

test-ligo = $(LIGO) run test ./test/ligo/$(1)
# ^ Run the given LIGO Test file

compile: ##@Contracts - Compile LIGO contracts
	@if [ ! -d ./compiled ]; then mkdir ./compiled ; fi
	@echo "Compiling contracts..."
## @$(call compile,generic_fa2/core/instance/NFT.mligo,fa2_nft.tz)
## @$(call compile,generic_fa2/core/instance/NFT.mligo,fa2_nft.json,--michelson-format json)
	@$(call compile,main.mligo,ticketing.tz)
	@$(call compile,main.mligo,ticketing.json,--michelson-format json)

.PHONY: test
test-ligo: ##@Contracts - Run LIGO tests
	@$(call test-ligo,ticketing.test.mligo)
# @$(call test-ligo,nft.premint.test.mligo)
# @$(call test-ligo,nft.mint.test.mligo)
# @$(call test-ligo,nft.airdrop.test.mligo)
# @$(call test-ligo,nft.changeallocation.test.mligo)
# @$(call test-ligo,nft.changeminteedwallet.test.mligo)

test-integration: ##@Contracts - Run integration tests
	$(MAKE) deploy
	@npm run test

clean: ##@Contracts - Contracts clean up
	@echo "Are you sure you want to DELETE ALL COMPILED CONTRACT FILES from your Compiled folder ? [y/N]" && read ans && if [ $${ans:-'N'} = 'y' ]; then rm -rf compiled/* ; fi

#######################################
#            SCRIPTS                  #
#######################################
install: ##@Scripts - Install NPM dependencies
	@if [ ! -f ./.env ]; then cp .env.dist .env ; fi
	@npm i

deploy: ##@Scripts - Deploy contracts
	@./scripts/deploy

# fixtures: ##@Scripts - Generate image fixtures
# 	@npx ts-node ./scripts/fixtures.ts

# prepare: ##@Scripts - Prepare a collection JSON
# 	@if [ ! -d ./assets/thumbnail ]; then mkdir assets/thumbnail ; fi
# 	@if [ ! -d ./assets/display ]; then mkdir assets/display ; fi
# 	@npx ts-node ./scripts/prepare.ts

# upload: ##@Scripts - Upload assets to IPFS and make their Metadata
# 	@npx ts-node ./scripts/upload.ts

# generate: ##@Scripts - Generate a collection (FACTORY=KTxx)
# 	@npx ts-node ./migrations/2_collection.ts $(FACTORY)

# local: ##@Scripts - Generate a JSON to avoid fetching IPFS
# 	@npx ts-node ./scripts/local.test

# unpin: ##@Scripts - Unpin (delete) all IPFS files on Pinata
# 	@echo "Are you sure you want to UNPIN ALL FILES from your Pinata Cloud account ? [y/N]" && read ans && if [ $${ans:-'N'} = 'y' ]; then npx ts-node ./scripts/unpin; fi

#######################################
#            SANDBOX                  #
#######################################
sandbox-start: ##@Sandbox - Start Flextesa sandbox
	@./scripts/run-sandbox

sandbox-stop: ##@Sandbox - Stop Flextesa sandbox
	@docker stop sandbox
