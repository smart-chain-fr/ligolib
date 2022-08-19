import { char2Bytes } from "@taquito/utils";
import { InMemorySigner } from '@taquito/signer';
import { TezosToolkit, MichelsonMap } from '@taquito/taquito';
import * as dotenv from 'dotenv'
import compiled from '../compiled/callback_betting.json';
import metadataJson from "./metadata/metadata_callback_betting.json";

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
    'isFinished': false,
    'isDraw': false,
    'isTeamOneWin': false,
    'startBetTime': 1660741034 + 1200,
    'closedBetTime': 1660741034 + 2400,
    'betsTeamOne': (new MichelsonMap()),
    'betsTeamOne_index': 0,
    'betsTeamOne_total': 0,
    'betsTeamTwo': (new MichelsonMap()),
    'betsTeamTwo_index': 0,
    'betsTeamTwo_total': 0,
    'closedTeamOneRate': 0,
    'metadata': (MichelsonMap.fromLiteral({
        '': char2Bytes("tezos-storage:contents"),
        'contents': char2Bytes(JSON.stringify(metadataJson))
    }))
};

async function orig() {
    try {
        // Originate a callback_betting contract
        const callback_betting_originated = await Tezos.contract.originate({
            code: compiled,
            storage: store
        });
        console.log(`Waiting for callback_betting origination ${callback_betting_originated.contractAddress} to be confirmed...`);
        await callback_betting_originated.confirmation(2);
        console.log('Confirmed callback_betting origination : ', callback_betting_originated.contractAddress);
        console.log('tezos-client remember contract callback_betting ', callback_betting_originated.contractAddress, ' --force')
    } catch (error: any) {
        console.log(error)
    }
}
orig();
