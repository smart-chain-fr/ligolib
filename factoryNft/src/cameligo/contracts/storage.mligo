type collectionContract = address
type collectionOwner = address

type t = {
    all_collections : (collectionContract, collectionOwner) Big_map
    owned_collection : (collectionOwner, collectionContract set) Big_map
}

