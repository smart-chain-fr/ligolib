from unittest import TestCase
from contextlib import contextmanager
from copy import deepcopy
from pytezos import ContractInterface, MichelsonRuntimeError, pytezos
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
compiled_contract_path = "../compiled/indice.tz"
initial_storage = ContractInterface.from_file(compiled_contract_path).storage.dummy()
initial_storage = 8

missing_entrypoint_receivevalue = "the targeted contract has not entrypoint receiveValue"

class IndiceContractTest(TestCase):
    @classmethod
    def setUpClass(cls):
        cls.indice = ContractInterface.from_file(compiled_contract_path)
        cls.maxDiff = None

    @contextmanager
    def raisesMichelsonError(self, error_message):
        with self.assertRaises(MichelsonRuntimeError) as r:
            yield r

        error_msg = r.exception.format_stdout()
        if "FAILWITH" in error_msg:
            self.assertEqual(f"FAILWITH: '{error_message}'", r.exception.format_stdout())
        else:
            self.assertEqual(f"'{error_message}': ", r.exception.format_stdout())

    #######################
    # Tests for Increment #
    #######################

    def test_increment_should_work(self):
        # Init
        init_storage = deepcopy(initial_storage)
        # Execute entrypoint
        increment_param = 1
        res = self.indice.increment(increment_param).interpret(storage=init_storage, sender=admin)
        self.assertEqual(res.storage, initial_storage + increment_param)
        self.assertEqual([], res.operations)

    #######################
    # Tests for Decrement #
    #######################

    def test_decrement_should_work(self):
        # Init
        init_storage = deepcopy(initial_storage)
        # Execute entrypoint
        increment_param = 1
        res = self.indice.decrement(increment_param).interpret(storage=init_storage, sender=admin)
        self.assertEqual(res.storage, initial_storage - increment_param)
        self.assertEqual([], res.operations)

    #######################
    # Tests for sendValue #
    #######################

    def test_send_value_should_work(self):
        # Init
        init_storage = deepcopy(initial_storage)
        # Execute entrypoint
        res = self.indice.sendValue().interpret(storage=init_storage, sender=advisorAddress)
        self.assertEqual(res.storage, initial_storage)
        self.assertEqual(len(res.operations), 1)
        self.assertEqual(res.operations[0]['destination'], advisorAddress)
        self.assertEqual(int(res.operations[0]['amount']), 0)
        self.assertEqual(res.operations[0]['parameters']['entrypoint'], "receiveValue")
        self.assertEqual(int(res.operations[0]['parameters']['value']['int']), initial_storage)
        
    def test_send_value_should_fail(self):
        # Init
        init_storage = deepcopy(initial_storage)
        # Execute entrypoint
        with self.raisesMichelsonError(missing_entrypoint_receivevalue):
            self.indice.sendValue().interpret(storage=init_storage, sender=alice)
