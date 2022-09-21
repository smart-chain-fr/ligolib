#import "./helpers/assert.mligo" "Assert"
#import "./bootstrap/bootstrap.mligo" "Bootstrap"
#import "./helpers/log.mligo" "Log"
#import "./helpers/ticketer.mligo" "Ticketer_helper"
#import "../src/ticketer.mligo" "Ticketer"

let () = Log.describe("[Buy_ticket] test suite")

let bootstrap () = Bootstrap.boot(400mutez)

let test_success =
    let (accounts, tckt) = bootstrap() in
    let (alice, _bob) = accounts in
    let () = Test.set_source alice in
    let () = Ticketer_helper.buy_ticket_success(1200mutez, tckt.contr) in
    Ticketer_helper.assert_has_tickets(tckt.addr, alice, 3n)

let test_failure_wrong_amount =
    let (accounts, tckt) = bootstrap() in
    let (alice, _bob) = accounts in
    let () = Test.set_source alice in
    let r = Ticketer_helper.buy_ticket(300mutez, tckt.contr) in
    Assert.string_failure r Ticketer.Errors.wrong_amount
