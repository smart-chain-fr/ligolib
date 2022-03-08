#import "tezos-ligo/lib/fa2/nft/NFT.mligo" "NFT_FA2"



type generate_collection_param = {
    name : string;
    token_ids : nat list;
    token_metas : NFT_FA2.TokenMetadata.t
}

type t = GenerateCollection of generate_collection_param | Nothing of unit