import { InMemorySigner } from '@taquito/signer';
import { TezosToolkit, MichelsonMap } from '@taquito/taquito';
import advisor from '../compiled/advisor.json';
import indice from '../compiled/indice.json';
import * as dotenv from 'dotenv'

dotenv.config(({path:__dirname+'/.env'}))

const rpc = process.env.RPC; //"http://127.0.0.1:8732"
const pk: string = "edskRuatoqjfYJ2iY6cMKtYakCECcL537iM7U21Mz4ieW3J51L9AZcHaxziWPZSEq4A8hu5e5eJzvzTY1SdwKNF8Pkpg5M6Xev";
const Tezos = new TezosToolkit(rpc);
const signer = new InMemorySigner(pk);
Tezos.setProvider({ signer: signer })

const admin = process.env.ADMIN_ADDRESS;
let indice_address = process.env.INDICE_CONTRACT_ADDRESS || undefined;
let advisor_address = process.env.ADVISOR_CONTRACT_ADDRESS || undefined;

const indice_initial_value = 4
const advisor_initial_result = false
const lambda_algorithm = "{ PUSH int 10 ; SWAP ; COMPARE ; LT ; IF { PUSH bool True } { PUSH bool False } }"

// let fa2_reward_ledger = new MichelsonMap();
// fa2_reward_ledger.set({0:reward_reserve_address, 1:reward_fa2_token_id}, rewards);

async function orig() {

    let indice_store = indice_initial_value

    let advisor_store = {
        'indiceAddress' : indice_address,
        'algorithm' : lambda_algorithm,
        'result' : advisor_initial_result
    }

    try {
        // Originate an Indice contract
        const indice_originated = await Tezos.contract.originate({
            code: indice,
            storage: indice_store,
        })
        console.log(`Waiting for INDICE ${indice_originated.contractAddress} to be confirmed...`);
        await indice_originated.confirmation(2);
        console.log('confirmed INDICE: ', indice_originated.contractAddress);
        indice_address = indice_originated.contractAddress;              
        advisor_store.indiceAddress = indice_address;

        // Originate a ADVISOR
        const advisor_originated = await Tezos.contract.originate({
            code: advisor,
            storage: advisor_store,
        })
        console.log(`Waiting for ADVISOR ${advisor_originated.contractAddress} to be confirmed...`);
        await advisor_originated.confirmation(2);
        console.log('confirmed ADVISOR: ', advisor_originated.contractAddress);
        advisor_address = advisor_originated.contractAddress;
       
        console.log("./tezos-client remember contract INDICE", indice_address)
        console.log("./tezos-client remember contract ADVISOR", advisor_address)

    } catch (error: any) {
        console.log(error)
    }
}

orig();
