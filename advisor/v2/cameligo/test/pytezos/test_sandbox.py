from unittest import TestCase
from contextlib import contextmanager
from copy import deepcopy
from pytezos import ContractInterface, MichelsonRuntimeError, pytezos
from pytezos.sandbox.node import SandboxedNodeTestCase
from pytezos.contract.result import ContractCallResult
from pytezos import michelson_to_micheline
# from pytezos.michelson.types.big_map import big_map_diff_to_lazy_diff
# from pytezos.michelson.types.option import OptionType
# from pytezos.michelson.types.domain import LambdaType
# from pytezos.michelson.types.option import SomeLiteral, NoneLiteral
# from pytezos import michelson_to_micheline
# from typing import Optional
# import time
# import json 

alice = 'tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur'
admin = 'tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK'
bob = 'tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF'

advisorAddress = "KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" # Hardcoded advisor address for tests
advisor_compiled_contract_path = "../../compiled/advisor.tz"

indice_compiled_contract_path = "../../compiled/indice.tz"
advisor_initial_storage = ContractInterface.from_file(advisor_compiled_contract_path).storage.dummy()
initial_storage = 6
initial_storageB = 6

missing_entrypoint_receivevalue = "the targeted contract has not entrypoint receiveValue"

class SandboxedContractTest(SandboxedNodeTestCase):
    def test_deploy_contract(self):
        # Create client
        client = self.client.using(key='bootstrap1')
        client.reveal()

        # Originate contract with initial storage
        indice_contract = ContractInterface.from_file(indice_compiled_contract_path)
        opg = indice_contract.using(shell=self.get_node_url(), key='bootstrap1').originate(initial_storage=initial_storage)
        opg = opg.fill().sign().inject()

        self.bake_block()

        # Find originated contract address by operation hash
        opg = client.shell.blocks['head':].find_operation(opg['hash'])
        indice_contract_address = opg['contents'][0]['metadata']['operation_result']['originated_contracts'][0]

        # print("Indice contract deployed at ", indice_contract_address)
        # Load originated contract from blockchain
        indice_originated_contract = client.contract(indice_contract_address).using(shell=self.get_node_url(), key='bootstrap1')

        # Perform real contract call

        increment_param = 1
        call = indice_originated_contract.increment(increment_param) #.interpret(storage=init_storage, sender=admin)
        opg = call.inject()

        self.bake_block()

        # Get injected operation and convert to ContractCallResult
        opg = client.shell.blocks['head':].find_operation(opg['hash'])
        result = ContractCallResult.from_operation_group(opg)[0]

        # print("Indice call Increment done resulting storage", int(result.storage['int']))
        self.assertEqual(int(result.storage['int']), initial_storage + increment_param)


        # Originate contract indiceB with initial storage
        indiceB_contract = ContractInterface.from_file(indice_compiled_contract_path)
        opg = indiceB_contract.using(shell=self.get_node_url(), key='bootstrap1').originate(initial_storage=initial_storageB)
        opg = opg.fill().sign().inject()

        self.bake_block()

        # Find originated contract address by operation hash
        opg = client.shell.blocks['head':].find_operation(opg['hash'])
        indiceB_contract_address = opg['contents'][0]['metadata']['operation_result']['originated_contracts'][0]

        # print("IndiceB contract deployed at ", indiceB_contract_address)
        # Load originated contract from blockchain
        indiceB_originated_contract = client.contract(indiceB_contract_address).using(shell=self.get_node_url(), key='bootstrap1')


        # deploy advisor contract
        advisor_contract = ContractInterface.from_file(advisor_compiled_contract_path)

        advisor_initial_storage['indices'] = [ {"contractAddress":indice_contract_address, "viewName": "indice_value"}, {"contractAddress":indiceB_contract_address, "viewName": "indice_value"} ]
        # advisor_initial_storage['algorithm'] = "{ PUSH int 10 ; SWAP ; COMPARE ; LT ; IF { PUSH bool True } { PUSH bool False } }"
        advisor_initial_storage['algorithm'] = '{ IF_CONS { SWAP ; DROP ; SOME } { NONE int } ; IF_NONE { PUSH string "missing value" ; FAILWITH } { PUSH int 10 ; SWAP ; COMPARE ; LT ; IF { PUSH bool True } { PUSH bool False } }'
        advisor_initial_storage['result'] = False
        opg = advisor_contract.using(shell=self.get_node_url(), key='bootstrap1').originate(initial_storage=advisor_initial_storage)
        opg = opg.fill().sign().inject()

        self.bake_block()

        # Find originated contract address by operation hash
        opg = client.shell.blocks['head':].find_operation(opg['hash'])
        advisor_contract_address = opg['contents'][0]['metadata']['operation_result']['originated_contracts'][0]
        # print("Advisor contract deployed at ", advisor_contract_address)
        
        # Load originated contract from blockchain
        advisor_originated_contract = client.contract(advisor_contract_address).using(shell=self.get_node_url(), key='bootstrap1')

        # Perform real contract call
        # call = originated_contract.default("bar")
        call = advisor_originated_contract.executeAlgorithm() #.interpret(storage=init_storage, sender=admin)
        opg = call.inject()

        self.bake_block()

        # Get injected operation and convert to ContractCallResult
        opg = client.shell.blocks['head':].find_operation(opg['hash'])
        all_result = ContractCallResult.from_operation_group(opg)
        #print(all_result[0].storage)
        self.assertEqual(len(all_result), 1)
        self.assertEqual(len(all_result[0].operations), 0)
        self.assertEqual(bool(all_result[0].storage['args'][1]['prim']), True)
        
