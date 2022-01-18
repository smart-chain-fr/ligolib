from unittest import TestCase
from contextlib import contextmanager
from copy import deepcopy
from pytezos import ContractInterface, MichelsonRuntimeError, pytezos
from pytezos.michelson.types.big_map import big_map_diff_to_lazy_diff
from pytezos.michelson.types.option import OptionType
from pytezos.michelson.types.domain import LambdaType
from pytezos.michelson.types.option import SomeLiteral, NoneLiteral
from pytezos import michelson_to_micheline
from typing import Optional
import time
import json 

alice = 'tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur'
admin = 'tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK'
bob = 'tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF'


indiceAddress = "KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" # Hardcoded farm address for tests
compiled_contract_path = "../../compiled/advisor.tz"
initial_lambda = "{ PUSH int 10 ; SWAP ; COMPARE ; LT ; IF { PUSH bool True } { PUSH bool False } }"
initial_storage = ContractInterface.from_file(compiled_contract_path).storage.dummy()
initial_storage["indiceAddress"] = indiceAddress
initial_storage["algorithm"] = initial_lambda 
initial_storage["result"] = False
# initial_result : Optional[bool] = None
# initial_result : Optional[bool] = False
# initial_storage["result"] = initial_result
unknownView  = "View indice_value not found"


class AdvisorContractTest(TestCase):
    @classmethod
    def setUpClass(cls):
        cls.advisor = ContractInterface.from_file(compiled_contract_path)
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

    #############################
    # Tests for changeAlgorithm #
    #############################

    def test_change_algorithm_should_work(self):
        # Init
        init_storage = deepcopy(initial_storage)
        # Execute entrypoint
        new_lambda = "{ PUSH int 10 ; SWAP ; COMPARE ; LT ; IF { PUSH bool True } { PUSH bool False } }"
        res = self.advisor.changeAlgorithm(new_lambda).interpret(storage=init_storage, sender=admin)
        self.assertEqual(new_lambda, res.storage["algorithm"])
        self.assertEqual([], res.operations)

    ##############################
    # Tests for ExecuteAlgorithm #
    ##############################

    # This unit test will fail because call_view reach an undeployed contract 
    # def test_execute_algorithm_should_work(self):
    #     # Init
    #     init_storage = deepcopy(initial_storage)
    #     # Execute entrypoint
    #     res = self.advisor.executeAlgorithm().interpret(storage=init_storage, sender=alice)
    #     self.assertEqual(res.storage["result"], False)
    #     self.assertEqual(res.storage["indiceAddress"], initial_storage["indiceAddress"])
    #     self.assertEqual(res.storage["algorithm"], initial_storage["algorithm"])
    #     self.assertEqual(len(res.operations), 0)

    def test_execute_algorithm_should_fail(self):
        # Init
        init_storage = deepcopy(initial_storage)
        # Execute entrypoint
        with self.raisesMichelsonError(unknownView):
            self.advisor.executeAlgorithm().interpret(storage=init_storage, sender=alice)
