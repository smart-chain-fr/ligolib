module Types = struct
    type commit_param = {
        secret_action : chest
    }

    type reveal_param = chest_key * nat

    type reset_param = {
        min : nat;
        max : nat
    }

    type t = Commit of commit_param | Reveal of reveal_param | Reset of reset_param
end 