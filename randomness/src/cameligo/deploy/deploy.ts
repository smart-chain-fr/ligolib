import { InMemorySigner } from '@taquito/signer';
import { TezosToolkit, MichelsonMap } from '@taquito/taquito';
import random from '../compiled/random.json';
import * as dotenv from 'dotenv'

dotenv.config(({path:__dirname+'/.env'}))

const rpc = process.env.RPC; //"http://127.0.0.1:8732"
const pk: string = process.env.ADMIN_PK || undefined;
const Tezos = new TezosToolkit(rpc);
const signer = new InMemorySigner(pk);
Tezos.setProvider({ signer: signer })

const admin = process.env.ADMIN_ADDRESS;
let random_address = process.env.RANDOM_CONTRACT_ADDRESS || undefined;

const random_initial_value = 4
// participants : address set;
// secrets : (address, chest) map;
// decoded_payloads: (address, bytes) map;
// result : bytes option

async function orig() {

    let random_store = random_initial_value

    try {
        // Originate an Random contract
        if (random_address === undefined) {
            const random_originated = await Tezos.contract.originate({
                code: random,
                storage: random_store,
            })
            console.log(`Waiting for RANDOM ${random_originated.contractAddress} to be confirmed...`);
            await random_originated.confirmation(2);
            console.log('confirmed RANDOM: ', random_originated.contractAddress);
            random_address = random_originated.contractAddress;              
        }
       
        console.log("./tezos-client remember contract RANDOM", random_address)
        // console.log("tezos-client transfer 0 from ", admin, " to ", advisor_address, " --entrypoint \"executeAlgorithm\" --arg \"Unit\"")

    } catch (error: any) {
        console.log(error)
    }
}

orig();
