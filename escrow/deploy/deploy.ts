import * as dotenv from 'dotenv'
import { TezosToolkit, MichelsonMap } from '@taquito/taquito';
import { InMemorySigner } from '@taquito/signer';
import { char2Bytes } from "@taquito/utils";
import compiled from '../contracts/cameligo/compiled/factory.json';
import metadataJson from "./metadata/factory.json";

dotenv.config(({ path: __dirname + '/../.env' }))

const rpc = (process.env.TZ_RPC);
const Tezos = new TezosToolkit(rpc);

const prk: string = (process.env.ADMIN_PRK);
const signature = new InMemorySigner(prk);
Tezos.setProvider({ signer: signature })

Tezos.tz
    .getBalance(process.env.ADMIN_ADDRESS)
    .then((balance) => console.log(`Signer balance : ${balance.toNumber() / 1000000} ꜩ`))
    .catch((error) => console.log(JSON.stringify(error)));

const deploy = async () => {
    let store = {
        // admin           : (process.env.ADMIN_ADDRESS),
        // is_paused       : false,
        // currencies      : (new (MichelsonMap)),
        escrows_index   : 0,
        escrows         : (new (MichelsonMap)),
        // metadata    : (MichelsonMap.fromLiteral({
        //     ''          : char2Bytes('tezos-storage:contents'),
        //     contents    : char2Bytes(JSON.stringify(metadataJson))
        // }))
    };

    async function orig() {
        try {
            const factory_originated = await Tezos.contract.originate({
                code: compiled,
                storage: store
            });
            console.log(`Waiting for Escrow Factory origination ${factory_originated.contractAddress} to be confirmed...`);
            await factory_originated.confirmation(2);
            console.log('Confirmed Escrow Factory origination : ', factory_originated.contractAddress);
            console.log('tezos-client remember contract escrowFactory ', factory_originated.contractAddress, ' --force')
            console.log('tezos-client -E ', rpc,' get contract storage for ', factory_originated.contractAddress)
        } catch (error: any) {
            console.log(error)
        }
    }
    orig();
};

deploy()