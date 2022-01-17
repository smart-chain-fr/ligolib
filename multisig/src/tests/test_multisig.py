from unittest import TestCase
from contextlib import contextmanager
from copy import deepcopy
from pytezos import ContractInterface, MichelsonRuntimeError, pytezos
from pytezos.michelson.types.option import SomeLiteral, NoneLiteral
from typing import List, Dict

compiled_contract_path: str = "Multisig.tz"

initial_storage = ContractInterface.from_file(compiled_contract_path).storage.dummy()

alice: str = 'tz1hNVs94TTjZh6BZ1PM5HL83A7aiZXkQ8ur'
bob: str = 'tz1c6PPijJnZYjKiSQND4pMtGMg6csGeAiiF'
charly: str = 'tz1fABJ97CJMSP2DKrQx2HAFazh6GgahQ7ZK'
oscar: str = 'tz1Phy92c2n817D17dUGzxNgw1qCkNSTWZY2'
fox: str = 'tz1XH5UyhRCUmCdUUbqD4tZaaqRTgGaFXt7q'
unknown: str = 'tz1UCFixZ2aZg4FJezcNtT5U6XLJ57b3yyPN'
fa12: str = 'KT1SjXiUX63QvdNMcM2m492f7kuf8JxXRLp4'
TOKEN_AMOUNT: int = 1000

initial_storage["signers"]: List[str] = [alice, bob, charly, oscar, fox]
initial_storage["threshold"]: int = 3
initial_storage["operation_map"]: Dict[int, str] = dict()
initial_storage["operation_counter"]: int = 0

only_signer: str = "Only one of the contract signer can create an operation"
amount_must_be_zero_tez: str = "You must not send Tezos to the smart contract"
unknown_contract_entrypoint: str = "Cannot connect to the target transfer token entrypoint"
no_operation_exist: str = "No operation exists for this counter"
has_already_signed: str = "You have already signed this operation"


class MultiSigContractTest(TestCase):
    @classmethod
    def setUpClass(cls):
        cls.multisig = ContractInterface.from_file(compiled_contract_path)
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

    def test_create_operation_should_work(self):
        """One of the signers creates a multisig operation request, so it works"""
        init_storage = deepcopy(initial_storage)
        params = {
            "target_fa12": fa12,
            "target_to": bob,
            "token_amount": TOKEN_AMOUNT
        }
        expected_operation_request = {
            "target_to": bob,
            "target_fa12": fa12,
            "token_amount": TOKEN_AMOUNT,
            "timestamp": 0,
            "approved_signers": [],
            "executed": False
        }
        res = self.multisig.create_operation(params).interpret(storage=init_storage, sender=bob)
        self.assertDictEqual(res.storage["operation_map"][0], expected_operation_request)
        self.assertEqual(res.storage["operation_counter"], init_storage["operation_counter"] + 1)
        self.assertEqual(res.operations, [])

    def test_create_operation_not_signer_should_not_work(self):
        """A random person, not one of the signers, tries to create a multisig operation request, so it doesn't work"""
        init_storage = deepcopy(initial_storage)
        params = {
            "target_fa12": fa12,
            "target_to": bob,
            "token_amount": TOKEN_AMOUNT
        }
        with self.raisesMichelsonError(only_signer):
            self.multisig.create_operation(params).interpret(storage=init_storage, sender=unknown)

    def test_sign_operation_signer_should_work(self):
        """One of the signers signs the operation request"""
        init_storage = deepcopy(initial_storage)
        init_storage["operation_map"][1] = {
            "target_to": bob,
            "target_fa12": fa12,
            "token_amount": TOKEN_AMOUNT,
            "timestamp": 0,
            "approved_signers": [],
            "executed": False
        }
        init_storage["operation_counter"] += 1
        res = self.multisig.sign(1).interpret(storage=init_storage, sender=alice)
        self.assertEqual(res.storage["operation_map"][1]["approved_signers"], [alice])
        self.assertEqual(res.operations, [])

    def test_sign_operation_signer_should_execute_transaction(self):
        """Enough signers sign the operation request, so it's executed"""
        init_storage = deepcopy(initial_storage)
        init_storage["operation_map"][1] = {
            "target_to": bob,
            "target_fa12": fa12,
            "token_amount": TOKEN_AMOUNT,
            "timestamp": 0,
            "approved_signers": [alice, bob],
            "executed": False
        }
        init_storage["operation_counter"] += 1
        expected_operation_request = {
            "target_to": bob,
            "target_fa12": fa12,
            "token_amount": TOKEN_AMOUNT,
            "timestamp": 0,
            "approved_signers": [alice, bob, charly],
            "executed": True
        }

        res = self.multisig.sign(1).interpret(storage=init_storage, sender=charly)

        self.assertSetEqual(set(res.storage["operation_map"][1]["approved_signers"]),
                            set(expected_operation_request["approved_signers"]))
        self.assertTrue(res.storage["operation_map"][1]["executed"])

        self.assertEqual(res.operations[0]["kind"], "transaction")
        self.assertEqual(res.operations[0]["destination"], fa12)
        self.assertEqual(res.operations[0]["amount"], '0')
        self.assertEqual(res.operations[0]["parameters"]["entrypoint"], "transfer")
        # self.assertEqual(res.operations[0]["parameters"]["value"]["args"][0]["string"], self.multisig.address)
        self.assertEqual(res.operations[0]["parameters"]["value"]["args"][1]["string"], bob)
        self.assertEqual(res.operations[0]["parameters"]["value"]["args"][2]["int"], str(TOKEN_AMOUNT))

    def test_unknown_tries_to_sign_should_fail(self):
        """A random person, not one of the signers, tries to sign an operation request, so it doesn't work"""
        init_storage = deepcopy(initial_storage)
        init_storage["operation_map"][1] = {
            "target_to": bob,
            "target_fa12": fa12,
            "token_amount": TOKEN_AMOUNT,
            "timestamp": 0,
            "approved_signers": [alice, bob],
            "executed": False
        }
        init_storage["operation_counter"] += 1
        with self.raisesMichelsonError(only_signer):
            self.multisig.sign(1).interpret(storage=init_storage, sender=unknown)

    def test_signer_tries_to_sign_unknown_request_should_fail(self):
        """A signer tries to sign a request that doesn't exist, so it fails"""
        init_storage = deepcopy(initial_storage)
        with self.raisesMichelsonError(no_operation_exist):
            self.multisig.sign(1).interpret(storage=init_storage, sender=bob)

    def test_unknown_tries_to_sign_unknown_request_should_fail(self):
        """A random person tries to sign a request that doesn't exist, so it fails"""
        init_storage = deepcopy(initial_storage)
        with self.raisesMichelsonError(no_operation_exist):
            self.multisig.sign(1).interpret(storage=init_storage, sender=bob)