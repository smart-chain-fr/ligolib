#import "./helpers/assert.mligo" "Assert"
#import "./bootstrap/bootstrap.mligo" "Bootstrap"
#import "./helpers/log.mligo" "Log"
#import "./helpers/ticketing.mligo" "Ticketing_helper"
#import "./helpers/nft.mligo" "NFT_helper"
#import "../../src/main.mligo" "Ticketing"

let () = Log.describe("[Ticketing] test suite")



let bootstrap () = Bootstrap.boot_ticketing()

let test_success_buy_ticket =
    let (accounts, ticketing) = bootstrap() in
    let (creator, _operator) = accounts in
    let () = Test.set_source creator in
    let () = Ticketing_helper.buy_ticket_success({
        ticket_type = "PARKING";
        ticket_amount = 2n;
        ticket_owner = creator;
    }, 20tez, ticketing.contr) in
    Ticketing_helper.assert_owned_ticket_amount(ticketing.addr, ticketing.taddr, creator, "PARKING", 1n)

// let test_success_nft_origination_with_uuid =
//     let (accounts, ticketing) = bootstrap() in
//     let (creator, operator) = accounts in
//     let () = Test.set_source operator in
//     let uuid : string = "abcdef" in
//     let () = Ticketing_helper.call_success({
//         name = "collection_name";
//         creator = creator;
//         metadata = metadata_empty;
//         uuid = (Some(uuid) : string option);
//         assets_infos = Ticketing_helper.dummy_assets_info(creator, operator);
//     }, ticketing.contr) in
//     let () = Ticketing_helper.assert_owned_collections_size(ticketing.taddr, creator, 1n) in
//     Ticketing_helper.assert_uuid_collection(ticketing.taddr, uuid, true)

// let test_failure_nft_origination_with_already_used_uuid =
//     let (accounts, ticketing) = bootstrap() in
//     let (creator, operator) = accounts in
//     let () = Test.set_source operator in
//     let uuid : string = "abcdef" in
//     let () = Ticketing_helper.call_success({
//         name = "collection_name";
//         creator = creator;
//         metadata = metadata_empty;
//         uuid = (Some(uuid) : string option);
//         assets_infos = Ticketing_helper.dummy_assets_info(creator, operator);
//     }, ticketing.contr) in
//     let () = Ticketing_helper.assert_owned_collections_size(ticketing.taddr, creator, 1n) in
//     let r2 = Ticketing_helper.call({
//         name = "collection_name_2";
//         creator = creator;
//         metadata = metadata_empty;
//         uuid = (Some(uuid) : string option);
//         assets_infos = Ticketing_helper.dummy_assets_info(creator, operator);
//     }, ticketing.contr) in
//     Assert.string_failure r2 Ticketing.Errors.uuid_already_used
