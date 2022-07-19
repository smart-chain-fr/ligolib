import { InMemorySigner } from '@taquito/signer';
import { TezosToolkit, MichelsonMap } from '@taquito/taquito';
import factory from '../compiled/factory.json';
import * as dotenv from 'dotenv'

dotenv.config(({path:__dirname+'/.env'}))

const rpc = process.env.RPC; //"http://127.0.0.1:8732"
const pk: string = process.env.ADMIN_PK || undefined;
const Tezos = new TezosToolkit(rpc);
const signer = new InMemorySigner(pk);
Tezos.setProvider({ signer: signer })

const admin = process.env.ADMIN_ADDRESS;
let factory_address = process.env.FACTORY_CONTRACT_ADDRESS || undefined;

async function orig() {

    let factory_store = {
        'all_collections' : new MichelsonMap(),
        'owned_collections': new MichelsonMap(), 
    }

    try {
        // Originate an Random contract
        if (factory_address === undefined) {
            const factory_originated = await Tezos.contract.originate({
                code: factory,
                storage: factory_store,
            })
            console.log(`Waiting for FACTORY ${factory_originated.contractAddress} to be confirmed...`);
            await factory_originated.confirmation(2);
            console.log('confirmed FACTORY: ', factory_originated.contractAddress);
            factory_address = factory_originated.contractAddress;              
        }
       
        console.log("./tezos-client remember contract FACTORY", factory_address)
        // console.log("tezos-client transfer 0 from ", admin, " to ", advisor_address, " --entrypoint \"executeAlgorithm\" --arg \"Unit\"")

    } catch (error: any) {
        console.log(error)
    }
}

orig();
