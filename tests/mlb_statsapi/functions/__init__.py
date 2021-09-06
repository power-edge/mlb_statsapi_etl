"""
created by nikos at 9/3/21
"""
import datetime
import importlib
import json
import os
import unittest
import uuid
import warnings


def log_stream_name(function_version):
    return (datetime.datetime.now().strftime("%Y/%m/%d/")
            + f'[{function_version}]'
            + str(uuid.uuid4()).replace("-", ""))


def load_test_event(module: str) -> dict:
    test = os.environ.get("MLB_STATSAPI__{}".format(module.replace(".", "_").upper()), module.replace(".", "/"))
    with open(f"{test}.json", "r") as f:
        return {
            "test": test,
            **json.load(f)
        }


class context:
    def __init__(self, function_name, log_group_name):
        self.function_name = function_name
        self.log_group_name = log_group_name
        self.function_version = "$TEST"
        self.log_stream_name = log_stream_name(self.function_version)


class LambdaTestCase(unittest.TestCase):
    from mlb_statsapi.model import StatsAPI
    event: dict

    @classmethod
    def setUpClass(cls) -> None:
        warnings.filterwarnings("ignore", category=ResourceWarning, message="unclosed.*<ssl.SSLSocket.*>")
        cls.event = load_test_event(cls.__module__)

    def setUp(self) -> None:
        self.function_name = self.event["context"]["function_name"]
        self.log_group_name = self.event["context"]["log_group_name"]
        self.lambda_module = importlib.import_module(".".join(self.__module__.split(".")[1:]).replace(".test_", "."))

    # noinspection PyUnresolvedReferences
    def test_lambda_handler(self):
        res = self.lambda_module.lambda_handler(self.event, context(self.function_name, self.log_group_name))
        print(json.dumps(res, indent=2))
        return res

