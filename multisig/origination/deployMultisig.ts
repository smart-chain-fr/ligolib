import { InMemorySigner } from '@taquito/signer'
import { TezosToolkit, MichelsonMap } from '@taquito/taquito'
import multisig from '../compiled/Multisig_mligo.json'

const rpc = 'https://hangzhounet.smartpy.io/'
const pk: string = ''
const Tezos = new TezosToolkit(rpc)
const signer = new InMemorySigner(pk)
Tezos.setProvider({ signer: signer })
const signers: Array<string> = [
  'tz1KeYsjjSCLEELMuiq1oXzVZmuJrZ15W4mv',
  'tz1MBWU1WkszFfkEER2pgn4ATKXE9ng7x1sR',
  'tz1TDZG4vFoA2xutZMYauUnS4HVucnAGQSpZ',
  'tz1fi3AzSELiXmvcrLKrLBUpYmq1vQGMxv9p',
  'tz1go7VWXhhkzdPMSL1CD7JujcqasFJc2hrF'
]

async function originate() {
  const storage = {
    signers: signers,
    threshold: 3,
    proposal_map: new MichelsonMap(),
    proposal_counter: 0
  }

  try {
    const originated = await Tezos.contract.originate({
      code: multisig,
      storage: storage
    })
    console.log(`Waiting for multisig ${originated.contractAddress} to be confirmed...`)
    await originated.confirmation(2)
    console.log('confirmed multisig: ', originated.contractAddress)
  } catch (error: any) {
    console.log(error)
  }
}

originate()
