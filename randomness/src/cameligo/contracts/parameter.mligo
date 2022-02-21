module Types = struct
    type commit_param = {
        secret_action : chest
    }

    type reveal_param = chest_key * nat

    type t = Commit of commit_param | Reveal of reveal_param 
end 