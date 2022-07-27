import { InMemorySigner } from '@taquito/signer';
import { TezosToolkit, MichelsonMap } from '@taquito/taquito';
import marketplace from '../contracts/marketplace/compiled/marketplace.json';
import auction from '../contracts/auction/compiled/auction.json';
import * as dotenv from 'dotenv'

dotenv.config(({path:__dirname+'/.env'}))

const rpc = process.env.RPC;
const pk: string = process.env.DEPLOYER_PK || undefined;
const Tezos = new TezosToolkit(rpc);
const signer = new InMemorySigner(pk);
Tezos.setProvider({ signer: signer })

const admin = process.env.ADMIN_ADDRESS;
const reserve = process.env.FEE_ADDRESS;
let auction_address = process.env.AUCTION_CONTRACT_ADDRESS || undefined;

async function orig() {

    let auction_store = {
        'admin' : admin,
        'min_bp_bid' : 10,
        'commissionFee' : 2500,
        'reserveAddress' : reserve,
        'royaltiesStorage' : reserve,
        'isPaused' : false,
        'nftSaleId' : 0,
        'auctionIdToAuction' : new MichelsonMap(),
        'extension_duration' : 1000,
    }

    try {
        // Originate an MARKETPLACE contract
        if (auction_address === undefined) {
            const auction_originated = await Tezos.contract.originate({
                code: auction,
                storage: auction_store,
            })
            console.log(`Waiting for AUCTION ${auction_originated.contractAddress} to be confirmed...`);
            await auction_originated.confirmation(2);
            console.log('confirmed AUCTION: ', auction_originated.contractAddress);
            auction_address = auction_originated.contractAddress;              
        }
       
        console.log("./tezos-client remember contract AUCTION", auction_address)
        // console.log("tezos-client transfer 0 from ", admin, " to ", advisor_address, " --entrypoint \"executeAlgorithm\" --arg \"Unit\"")

    } catch (error: any) {
        console.log(error)
    }
}

orig();
