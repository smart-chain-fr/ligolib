import { char2Bytes } from "@taquito/utils";
import { InMemorySigner } from '@taquito/signer';
import { TezosToolkit, MichelsonMap } from '@taquito/taquito';
import * as dotenv from 'dotenv'
import compiled from '../compiled/oracle.json';
import metadataJson from "./metadata/metadata_oracle.json";
import { outputFile } from "fs-extra";

dotenv.config(({ path: __dirname + '/.env' }))

const rpc = process.env.TZ_RPC;
const Tezos = new TezosToolkit(rpc || '');

const prk: string = (process.env.ADMIN_PRK || '');
const signature = new InMemorySigner(prk);
Tezos.setProvider({ signer: signature })

Tezos.tz
    .getBalance(process.env.ADMIN_ADDRESS || '')
    .then((balance) => console.log(`Signer balance : ${balance.toNumber() / 1000000} ꜩ`))
    .catch((error) => console.log(JSON.stringify(error)));

let store = {
    isPaused: false,
    manager: (process.env.ADMIN_ADDRESS || ''),
    signer: (process.env.ADMIN_ADDRESS || ''),
    events: (new MichelsonMap()),
    events_index: 0,
    metadata: (MichelsonMap.fromLiteral({
        '': char2Bytes('tezos-storage:contents'),
        contents: char2Bytes(JSON.stringify(metadataJson))
    }))
};

export const saveContractAddress = (name: string, address: string) =>
    outputFile(
        `${process.cwd()}/deployments/${name}.ts`,
        `export default "${address}";`
    );

async function orig() {
    try {
        // Originate a oracle contract
        const oracle_originated = await Tezos.contract.originate({
            code: compiled,
            storage: store
        });
        console.log(`Waiting for oracle origination ${oracle_originated.contractAddress} to be confirmed...`);
        await oracle_originated.confirmation(2);
        saveContractAddress('oracle', oracle_originated.contractAddress);
        console.log('Confirmed oracle origination : ', oracle_originated.contractAddress);
        console.log('tezos-client remember contract betting_oracle ', oracle_originated.contractAddress, ' --force')
    } catch (error: any) {
        console.log(error)
    }
}
orig();