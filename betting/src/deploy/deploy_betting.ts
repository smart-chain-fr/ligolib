import { char2Bytes } from "@taquito/utils";
import { InMemorySigner } from '@taquito/signer';
import { TezosToolkit, MichelsonMap } from '@taquito/taquito';
import * as dotenv from 'dotenv'
import compiled from '../compiled/betting.json';
import metadataJson from "./metadata/metadata_betting.json";

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

const getOracle = async () => {
    const args = process.argv.slice(2);
    const address = args[0];
    return address !== undefined
        ? address
        : (await import("../deployments/oracle")).default;
};

const deploy = async () => {
    const ORACLE_ADDRESS = await getOracle();

    let init_bet_config_type = {
        'is_betting_paused': false,
        'is_event_creation_paused': false,
        'min_bet_amount': 1000000,
        'retained_profit_quota': 10,
    }

    let store = {
        'manager': process.env.ADMIN_ADDRESS,
        'oracle_address': ORACLE_ADDRESS,
        'bet_config': init_bet_config_type,
        'events': (new (MichelsonMap)),
        'events_bets': (new (MichelsonMap)),
        'events_index': 0,
        'metadata': (MichelsonMap.fromLiteral({
            '': char2Bytes("tezos-storage:contents"),
            'contents': char2Bytes(JSON.stringify(metadataJson))
        }))
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
            console.log('tezos-client remember contract betting_betting ', betting_originated.contractAddress, ' --force')
        } catch (error: any) {
            console.log(error)
        }
    }
    orig();
};

deploy()