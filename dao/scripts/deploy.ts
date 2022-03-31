import dotenv from "dotenv";
import { MichelsonMap, TezosToolkit } from "@taquito/taquito";
import { InMemorySigner } from "@taquito/signer";
import code from "../compiled/dao.json";

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

        Tezos.setProvider({ signer });

        // create a JavaScript object to be used as initial storage
        // https://tezostaquito.io/docs/originate/#a-initializing-storage-using-a-plain-old-javascript-object
        const storage = {
            governance_token: "KT1AuAxBeB8sh17HhxK5iD8FGGgUQbnhG4m5",
            // ^ random address, please change for your own

            vault: new MichelsonMap(),
            // ^ should be left empty,
            // unless you want to fill-in some values for test purpose

            config: {
                deposit_amount: 4,
                refund_threshold: 32,
                quorum_threshold: 67,
                super_majority: 80,
                start_delay: 86400, // one day
                voting_period: 604800, // one week
                timelock_delay: 86400,
                timelock_period: 259200, // 3 days
                burn_address: "KT1CZMurPAjSfZqcn6LBUNUhG4byE6AJgDT6",
                // ^ on mainnet, thoses addresses can be used:
                // KT1CZMurPAjSfZqcn6LBUNUhG4byE6AJgDT6 (burner.crunchy.tez)
                // tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg
                // tz1burnburnburnburnburnburnburjAYjjX
            }, 
            // ^ example configuration

            next_outcome_id: 1,
            // ^ this should always be initialized with 1n

            outcomes: new MichelsonMap(),
            // ^ should be left empty,
            // unless you want to fill-in some values for test purpose
        };

        const op = await Tezos.contract.originate({ code, storage });
        await op.confirmation();
        console.log(`[OK] ${op.contractAddress}`);
    } catch (e) {
        console.log(e);
    }
};

deploy();
