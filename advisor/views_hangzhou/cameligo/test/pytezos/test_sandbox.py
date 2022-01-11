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

missing_entrypoint_receivevalue = "the targeted contract has not entrypoint receiveValue"

class SandboxedContractTest(SandboxedNodeTestCase):
    def test_deploy_contract(self):
        # Create client
        client = self.client.using(key='bootstrap1')
        client.reveal()

        print("debug")
        # Originate contract with initial storage
        #contract = ContractInterface.from_michelson(contract_michelson)
        indice_contract = ContractInterface.from_file(indice_compiled_contract_path)
        opg = indice_contract.using(shell=self.get_node_url(), key='bootstrap1').originate(initial_storage=initial_storage)
        opg = opg.fill().sign().inject()

        self.bake_block()

        # Find originated contract address by operation hash
        opg = client.shell.blocks['head':].find_operation(opg['hash'])
        indice_contract_address = opg['contents'][0]['metadata']['operation_result']['originated_contracts'][0]

        print("Indice contract deployed at ", indice_contract_address)
        # Load originated contract from blockchain
        indice_originated_contract = client.contract(indice_contract_address).using(shell=self.get_node_url(), key='bootstrap1')

        # Perform real contract call
        # call = originated_contract.default("bar")
        increment_param = 1
        call = indice_originated_contract.increment(increment_param) #.interpret(storage=init_storage, sender=admin)
        # self.assertEqual(res.storage, initial_storage + increment_param)
        # self.assertEqual([], res.operations)
        opg = call.inject()

        self.bake_block()

        # Get injected operation and convert to ContractCallResult
        opg = client.shell.blocks['head':].find_operation(opg['hash'])
        result = ContractCallResult.from_operation_group(opg)[0]

        print("Indice call Increment done resulting storage", int(result.storage['int']))
        self.assertEqual(int(result.storage['int']), initial_storage + increment_param)

        # deploy advisor contract
        advisor_contract = ContractInterface.from_file(advisor_compiled_contract_path)
        advisor_initial_storage['indiceAddress'] = indice_contract_address
        advisor_initial_storage['algorithm'] = "{ PUSH int 10 ; SWAP ; COMPARE ; LT ; IF { PUSH bool True } { PUSH bool False } }"
        advisor_initial_storage['result'] = False
        opg = advisor_contract.using(shell=self.get_node_url(), key='bootstrap1').originate(initial_storage=advisor_initial_storage)
        opg = opg.fill().sign().inject()

        self.bake_block()

        # Find originated contract address by operation hash
        opg = client.shell.blocks['head':].find_operation(opg['hash'])
        advisor_contract_address = opg['contents'][0]['metadata']['operation_result']['originated_contracts'][0]
        print("Advisor contract deployed at ", advisor_contract_address)
        # Load originated contract from blockchain
        advisor_originated_contract = client.contract(advisor_contract_address).using(shell=self.get_node_url(), key='bootstrap1')

        # Perform real contract call
        # call = originated_contract.default("bar")
        call = advisor_originated_contract.requestValue() #.interpret(storage=init_storage, sender=admin)
        opg = call.inject()

        self.bake_block()

        # Get injected operation and convert to ContractCallResult
        opg = client.shell.blocks['head':].find_operation(opg['hash'])
        all_result = ContractCallResult.from_operation_group(opg)
        self.assertEqual(len(all_result), 1)
        self.assertEqual(len(all_result[0].operations), 1)
        self.assertEqual(all_result[0].operations[0]['source'], advisor_contract_address)
        self.assertEqual(all_result[0].operations[0]['destination'], indice_contract_address)
        self.assertEqual(int(all_result[0].operations[0]['amount']), 0)
        self.assertEqual(all_result[0].operations[0]['parameters']['entrypoint'], "sendValue")
        
        ## print("Result advice", all_result[0].storage)
        # self.bake_block()
        # print(client.shell.blocks['head':].find_origination(contract_id=advisor_contract_address))
        # http://localhost:8732/chains/main/blocks/head/context/contracts/KT1BRudFZEXLYANgmZTka1xCDN5nWTMWY7SZ/storage


        call = indice_originated_contract.using(shell=self.get_node_url(), key=advisor_contract_address).sendValue()
        #call = indice_originated_contract.sendValue()
        opg = call.inject()

        self.bake_block()

        opg = client.shell.blocks['head':].find_operation(opg['hash'])
        result_sendvalue = ContractCallResult.from_operation_group(opg)[0]
        print(result_sendvalue[0].operations)
