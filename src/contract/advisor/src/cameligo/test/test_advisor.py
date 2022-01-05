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
# oscar = 'tz1Phy92c2n817D17dUGzxNgw1qCkNSTWZY2'
# fox = 'tz1XH5UyhRCUmCdUUbqD4tZaaqRTgGaFXt7q'

indiceAddress = "KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi" # Hardcoded farm address for tests
compiled_contract_path = "../compiled/advisor.tz"
initial_lambda = """{ 
            PUSH int 10 ; 
            SWAP ; 
            COMPARE ; 
            LT ; 
            IF { PUSH bool True } { PUSH bool False }
            }"""
initial_storage = ContractInterface.from_file(compiled_contract_path).storage.dummy()
initial_storage["indiceAddress"] = indiceAddress
initial_storage["algorithm"] = LambdaType.from_micheline_value(michelson_to_micheline(initial_lambda))
initial_storage["result"] = False
# initial_result : Optional[bool] = None
# initial_storage["result"] = initial_result
print(initial_storage["algorithm"].to_micheline_value())
missing_entrypoint_sendvalue  = "the targeted contract has not entrypoint sendValue"


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
        new_lambda = """{ 
            PUSH int 10 ; 
            SWAP ; 
            COMPARE ; 
            LT ; 
            IF { PUSH bool True } { PUSH bool False }
            }"""
        # new_algo_param = michelson_to_micheline(new_lambda)
        # new_lambda_string = "{ PUSH int 10 ; SWAP ; COMPARE ; LT ; IF { PUSH bool True } { PUSH bool False } }"
        res = self.advisor.changeAlgorithm(new_lambda).interpret(storage=init_storage, sender=admin)
        self.assertEqual(new_lambda, res.storage["algorithm"].to_micheline_value())
        self.assertEqual([], res.operations)

    def test_receive_value_should_work(self):
        # Init
        init_storage = deepcopy(initial_storage)
        # Execute entrypoint
        res = self.advisor.receiveValue(9).interpret(storage=init_storage, sender=admin)
        self.assertEqual(res.storage["result"], True)
        self.assertEqual([], res.operations)

    def test_request_value_should_work(self):
        # Init
        init_storage = deepcopy(initial_storage)
        # Execute entrypoint
        res = self.advisor.requestValue().interpret(storage=init_storage, sender=admin)
        self.assertEqual(res.storage["result"], False)
        self.assertEqual(res.storage["algorithm"], initial_storage["algorithm"])
        self.assertEqual(len(res.operations), 1)

    def test_request_value_should_fail(self):
        # Init
        init_storage = deepcopy(initial_storage)
        # Execute entrypoint
        with self.raisesMichelsonError(missing_entrypoint_sendvalue):
            self.advisor.requestValue().interpret(storage=init_storage, sender=alice, now=int(sec_week + sec_week/2))
