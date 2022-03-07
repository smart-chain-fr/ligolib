type generate_collection_param = {
    name : string;
}

type t = GenerateCollection of generate_collection_param | Nothing of unit