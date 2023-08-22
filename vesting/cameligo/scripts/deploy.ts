import dotenv from "dotenv";
import { MichelsonMap, TezosToolkit } from "@taquito/taquito";
import { InMemorySigner } from "@taquito/signer";
import { buf2hex } from "@taquito/utils";
import code from "../compiled/vesting.json";
import metadata from "./metadata.json";

// Read environment variables from .env file
dotenv.config();

// Initialize RPC connection
const Tezos = new TezosToolkit(process.env.NODE_URL);

// Deploy to configured node with configured secret key
const deploy = async () => {
    try {
        const signer = await InMemorySigner.fromSecretKey(
            process.env.SECRET_KEY
        );

        const now = Date.now();
        Tezos.setProvider({ signer });

        // create a JavaScript object to be used as initial storage
        // https://tezostaquito.io/docs/originate/#a-initializing-storage-using-a-plain-old-javascript-object
        const storage = {
            token_address : "KT1TwzD6zV3WeJ39ukuqxcfK2fJCnhvrdN1X",
            token_id : 0,
            beneficiaries : new MichelsonMap(),
            // revocable : false,
            release_duration : 3600,
            cliff_duration : 1200,
            admin: process.env.ADMIN,
            released : new MichelsonMap(),
            // revoked : false,
            revoked_addresses : new MichelsonMap(),
            vested_amount : 1000,
            // started : true,
            total_released : 0,
            // end_of_cliff : now + 1200,
            // vesting_end : now + 3600,
            // start : now,
            metadata: MichelsonMap.fromLiteral({
                "": buf2hex(Buffer.from("tezos-storage:contents")),
                contents: buf2hex(Buffer.from(JSON.stringify(metadata))),
            }),
            // ^ contract metadata (tzip-16)
            // https://tzip.tezosagora.org/proposal/tzip-16/
        };

        const op = await Tezos.contract.originate({ code, storage });
        await op.confirmation();
        console.log(`[OK] ${op.contractAddress}`);
    } catch (e) {
        console.log(e);
    }
};

deploy();
