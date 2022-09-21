module Constants =
  struct
    let no_operation : operation list = []
  end

module Errors =
  struct
  end

type storage = {ticketer : address; owner : address}
type result = operation list * storage

let consume (s : storage) =
  Constants.no_operation, s

let main (_, store : unit * storage) : result =
  consume (store)
