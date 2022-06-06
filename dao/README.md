# DAO

A modular example DAO contract on Tezos written in Ligolang.  

## Intro

This example DAO allows FA2 token holders to vote on proposals, which trigger
on-chain changes when accepted.

It is using token based quorum voting, requiring a given threshold of
participating tokens for a proposal to pass.

The contract code uses Ligo [modules](https://ligolang.org/docs/language-basics/modules/),
and the [tezos-ligo-fa2](https://www.npmjs.com/package/tezos-ligo-fa2) [package](https://ligolang.org/docs/advanced/package-management)

The used `FA2` token is expected to extend the standard with an on-chain view
`total_supply` returning the total supply of tokens, used as base for the
participation computation, see [example `FA2` in the test directory](./test/bootstrap/single_asset.mligo).

## Usage

1. Run `make install` to install dependencies
2. Run `make` to see available commands

## Docs

- [Specification](./docs/specification.md)
- [Lambdas](./docs/lambdas.md)
- [Tests](./docs/tests.md)

## Follow-Up

- Expand vote: add third "Pass" choice, add [Score Voting](https://en.wikipedia.org/wiki/Score_voting)
- Vote incentives with some staking mechanism
- `JSLigo`
- Mutation tests
- Optimizations (inline...)
- Attack tests (see last one: <https://twitter.com/ylv_io/status/1515773148465147926>)

## Resources

- <https://github.com/tezos-commons/baseDAO>
- <https://github.com/Hover-Labs/murmuration>
- <https://forum.salsadao.xyz/t/governance-principles-what-should-it-do-how-should-it-work-etc/52>
- <https://medium.com/@tstyle11/time-locks-5b644651e4a3>
- <https://github.com/kickflowio/flow-dao>
- <https://rekt.news>
- <https://soliditydeveloper.com/comp-governance>
- <https://medium.com/daostack/voting-options-in-daos-b86e5c69a3e3>
- <https://xord.com/research/curve-dao-a-brief-outlook-to-the-mechanism-of-dao/>
- <https://finance.yahoo.com/news/defi-projects-embrace-vote-locking-161806673.html?guccounter=1>
- <https://medium.com/block-science/dao-vulnerabilities-a-map-of-lido-governance-risks-opportunities-92bc6384ff68>
- <https://policyreview.info/glossary/permissionlessness>
- <https://medium.com/block-science/aligning-the-concept-of-decentralized-autonomous-organization-to-precedents-in-cybernetics-51344d1c1411>
- <https://sarahlu.notion.site/sarahlu/just-another-web3-reading-list-f917a3b6a81e4a9a8f947a236c0e141a>
