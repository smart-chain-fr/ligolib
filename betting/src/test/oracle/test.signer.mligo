#import "../../contracts/cameligo/oracle/errors.mligo" "Errors"
#import "helpers/bootstrap.mligo" "Bootstrap"
#import "helpers/helper.mligo" "Helper"
#import "helpers/assert.mligo" "Assert"
#import "helpers/log.mligo" "Log"

let () = Log.describe("[ChangeSigner] test suite")

let test_change_signer_from_manager_should_work =
    let (oracle_contract, oracle_taddress, elon, jeff, _, _, _) = Bootstrap.bootstrap_oracle() in
    let () = Assert.signer oracle_taddress jeff in

    let () = Helper.trsc_change_signer_success(oracle_contract, elon, elon) in
    let () = Assert.signer oracle_taddress elon in
    "OK"

let test_change_signer_from_signer_should_work =
    let (oracle_contract, oracle_taddress, elon, jeff, _, _, _) = Bootstrap.bootstrap_oracle() in
    let () = Assert.signer oracle_taddress jeff in

    let () = Helper.trsc_change_signer_success(oracle_contract, jeff, elon) in
    let () = Assert.signer oracle_taddress elon in
    "OK"

let test_change_signer_from_unauthorized_address_should_not_work =
    let (oracle_contract, oracle_taddress, _, jeff, alice, _, _) = Bootstrap.bootstrap_oracle() in
    let () = Assert.signer oracle_taddress jeff in

    let ret = Helper.trsc_change_signer (oracle_contract, alice, alice) in
    let () = Assert.string_failure ret Errors.not_manager_nor_signer in
    let () = Assert.signer oracle_taddress jeff in
    "OK"