# LigoLib
This repository holds various Tezos Smart-contracts written in CameLigo and JsLigo to demonstrate good practices


| Contract name         | Directory                                                                                            | Description                                                                                                                       | Tag |
|:----------------------|:-----------------------------------------------------------------------------------------------------|:----------------------------------------------------------------------------------------------------------------------------------|:----|
| Versionnable contract | [advisor/views_hangzhou](https://github.com/smart-chain-fr/Ligolib/tree/main/advisor/views_hangzhou) | Contract logic is based on lambdas that can be upgraded. This contract interactions with another contract (=> split data / logic) |     |
| Multisignature        | [multisig/src](https://github.com/smart-chain-fr/Ligolib/tree/main/multisig/src)                     | Basic multisignature contract that enables multiple users to decide wether the FA2 transfer should be approved or not             |     |
| Proxy                 | TBA                                                                                                  | Proxy contract that redirects user call to the last version of the deployed smart-contract                                        |     |

