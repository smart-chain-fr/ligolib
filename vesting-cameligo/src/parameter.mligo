type entrypoint_1_param = {
    name : string
}

type entrypoint_2_param = {
    name : string
}

type t = Entrypoint_1 of entrypoint_1_param | Entrypoint_2 of entrypoint_2_param
