type t = string

let undefined_token = "FA2_TOKEN_UNDEFINED"
let ins_balance     = "FA2_INSUFFICIENT_BALANCE"
let not_owner       = "FA2_NOT_OWNER"
let not_operator    = "FA2_NOT_OPERATOR"

// Following error might be used in commented block Operators.mligo : 30
// let no_transfer     = "FA2_TX_DENIED"

let only_sender_manage_operators = "The sender can only manage operators for his own token"
let only_admin = "FA2_NOT_ADMIN"