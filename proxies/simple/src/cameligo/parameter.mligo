module Types = struct
    type new_version_params = {
        label: string;
        dest: address;
    }

    type t = 
        TransferOwnership of address
        | AddVersion of new_version_params
        | SetVersion of string
        | Increment of int
        | Decrement of int
        | Reset
end
