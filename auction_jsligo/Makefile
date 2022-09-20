ligo_compiler=docker run --rm -v "$$PWD":"$$PWD" -w "$$PWD" ligolang/ligo:0.45.0

PROJECTROOT_OPT=--project-root .
PROTOCOL_OPT=--protocol jakarta
JSON_OPT=--michelson-format json

help:
	@echo  'Usage:'
	@echo  '  all             - Remove generated Michelson files, recompile smart contracts and lauch all tests'
	@echo  '  clean           - Remove generated Michelson files'
	@echo  '  compile         - Compiles smart contract Factory'
	@echo  '  test            - Run integration tests (written in Ligo)'
	@echo  '  deploy          - Deploy smart contracts advisor & indice (typescript using Taquito)'
	@echo  ''

all: clean compile test

compile: fa2_nft.tz nft_multi.tz factory auction

fa2_nft.tz: test/contracts/generic_fa2/core/instance/NFT.mligo
	@echo "Compiling smart contract FA2 to Michelson"
	@mkdir -p test/contracts/generic_fa2/compiled
	@$(ligo_compiler) compile contract $^ -e main $(PROTOCOL_OPT) $(PROJECTROOT_OPT) > test/contracts/generic_fa2/compiled/$@

nft_multi.tz: test/contracts/nft_multi/core/instance/NFT.mligo
	@echo "Compiling smart contract NFT_MULTI to Michelson"
	@mkdir -p test/contracts/nft_multi/compiled
	@$(ligo_compiler) compile contract $^ -e main $(PROTOCOL_OPT) $(PROJECTROOT_OPT) > test/contracts/nft_multi/compiled/$@


factory: factory.tz factory.json

factory.tz: test/contracts/factory/main.mligo
	@echo "Compiling smart contract Factory to Michelson"
	@mkdir -p test/contracts/factory/compiled
	@$(ligo_compiler) compile contract $^ -e main $(PROTOCOL_OPT) $(PROJECTROOT_OPT) > test/contracts/factory/compiled/$@

factory.json: test/contracts/factory/main.mligo
	@echo "Compiling smart contract Factory to Michelson in JSON format"
	@mkdir -p test/contracts/factory/compiled
	@$(ligo_compiler) compile contract $^ $(JSON_OPT) -e main $(PROTOCOL_OPT) $(PROJECTROOT_OPT) > test/contracts/factory/compiled/$@

auction: auction.tz auction.json

auction.tz: contracts/auction/main.jsligo
	@echo "Compiling smart contract Auction to Michelson"
	@mkdir -p contracts/auction/compiled
	@$(ligo_compiler) compile contract $^ -e main $(PROTOCOL_OPT) $(PROJECTROOT_OPT) > contracts/auction/compiled/$@

auction.json: contracts/auction/main.jsligo
	@echo "Compiling smart contract Auction to Michelson"
	@mkdir -p contracts/auction/compiled
	@$(ligo_compiler) compile contract $^ $(JSON_OPT) -e main $(PROTOCOL_OPT) $(PROJECTROOT_OPT) > contracts/auction/compiled/$@

clean: clean_fa2 clean_factory

clean_fa2:
	@echo "Removing FA2 Michelson file"
	@rm -f contracts/generic_fa2/compiled/*.tz

clean_factory:
	@echo "Removing Factory Michelson file"
	@rm -f contracts/factory/compiled/*.tz
	@rm -f contracts/factory/compiled/*.json


test: test_auction

test_auction: test_auction_set_nft test_auction_cancel test_auction_cancel_by_admin test_emergency_pause test_set_bid_order test_finalize_auction

test_auction_set_nft: test/auction/test_set_nft.mligo
	@echo "Running Auction integration tests"
	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT) $(PROJECTROOT_OPT) --no-warn

test_auction_cancel: test/auction/test_cancel_auction.mligo
	@echo "Running Auction integration tests"
	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT) $(PROJECTROOT_OPT) --no-warn

test_auction_cancel_by_admin: test/auction/test_admin_cancel_auction.mligo
	@echo "Running Auction integration tests"
	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT) $(PROJECTROOT_OPT) --no-warn

test_emergency_pause: test/auction/test_emergency_pause.mligo
	@echo "Running Auction integration tests"
	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT) $(PROJECTROOT_OPT) --no-warn

test_set_bid_order: test/auction/test_set_bid_order.mligo
	@echo "Running Auction integration tests"
	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT) $(PROJECTROOT_OPT) --no-warn

test_finalize_auction: test/auction/test_finalize_auction.mligo
	@echo "Running Auction integration tests"
	@$(ligo_compiler) run test $^ $(PROTOCOL_OPT) $(PROJECTROOT_OPT) --no-warn

deploy: deploy_auction

deploy_auction: deploy_node_modules deploy/deploy_auction.ts
	@echo "Deploying AUCTION contract"
	@cd deploy && tsc deploy_auction.ts --resolveJsonModule -esModuleInterop
	@node deploy/deploy_auction.js

deploy_node_modules:
	@echo "Install node modules"
	@cd deploy && npm install
