import { InMemorySigner } from '@taquito/signer';
import { TezosToolkit, MichelsonMap } from '@taquito/taquito';
import compiled from '../compiled/betting.json';
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
    '' : ''
};

async function orig() {
    try {
        // Originate a betting contract
        const betting_originated = await Tezos.contract.originate({
            code: compiled,
            storage: store
        });
        console.log(`Waiting for betting origination ${betting_originated.contractAddress} to be confirmed...`);
        await betting_originated.confirmation(2);
        console.log('Confirmed betting origination : ', betting_originated.contractAddress);
        console.log('tezos-client remember contract betting_betting ', betting_originated.contractAddress)
    } catch (error: any) {
        console.log(error)
    }
}
orig();