import { InMemorySigner } from '@taquito/signer';
import { TezosToolkit, MichelsonMap } from '@taquito/taquito';
import compiled from '../compiled/callback.json';
import * as dotenv from 'dotenv'

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
    'name': 'name',
    'videogame': 'videogame',
    'begin_at': '2000-01-01t10:10:10Z',
    'end_at': '2000-01-01t10:10:10Z',
    'modified_at': '2000-01-01t10:10:10Z',
    'opponents':
    {
        'teamOne': 'teamOne',
        'teamTwo': 'teamTwo'
    },
    'isFinished': true,
    'isDraw': true,
    'isTeamOneWin': false
}

async function orig() {
    try {
        // Originate a Callback contract
        const callback_originated = await Tezos.contract.originate({
            code: compiled,
            storage: store
        });
        console.log(`Waiting for Callback origination ${callback_originated.contractAddress} to be confirmed...`);
        await callback_originated.confirmation(2);
        console.log('Confirmed Callback origination : ', callback_originated.contractAddress);
        console.log('tezos-client remember contract betting_callback ', callback_originated.contractAddress)
    } catch (error: any) {
        console.log(error)
    }
}
orig();
