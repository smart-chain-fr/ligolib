import { char2Bytes } from "@taquito/utils";
import { InMemorySigner } from '@taquito/signer';
import { TezosToolkit, MichelsonMap } from '@taquito/taquito';
import * as dotenv from 'dotenv'
import compiled from '../compiled/callback_oracle.json';
import metadataJson from "./metadata/metadata_callback_oracle.json";

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
    'name': '',
    'videogame': '',
    'begin_at': 1660741034,
    'end_at': 1660741034 + 3600,
    'modified_at': 1660741034,
    'opponents': { 'teamOne': '', 'teamTwo': '' },
    'isFinalized': false,
    'isDraw': false,
    'isTeamOneWin': false,
    'metadata': (MichelsonMap.fromLiteral({
        '': char2Bytes("tezos-storage:contents"),
        'contents': char2Bytes(JSON.stringify(metadataJson))
    }))
};

async function orig() {
    try {
        // Originate a callback_oracle contract
        const callback_oracle_originated = await Tezos.contract.originate({
            code: compiled,
            storage: store
        });
        console.log(`Waiting for callback_oracle origination ${callback_oracle_originated.contractAddress} to be confirmed...`);
        await callback_oracle_originated.confirmation(2);
        console.log('Confirmed callback_oracle origination : ', callback_oracle_originated.contractAddress);
        console.log('tezos-client remember contract callback_oracle ', callback_oracle_originated.contractAddress, ' --force')
    } catch (error: any) {
        console.log(error)
    }
}
orig();
