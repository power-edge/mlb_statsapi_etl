"""
created by nikos at 9/3/21
"""
import json
import os
from tests.mlb_statsapi.functions import LambdaTestCase
import unittest


class TestSetScheduledGames(LambdaTestCase):

    def test_get_games(self):
        self.lambda_module.get_games(self.event["date"])


if __name__ == '__main__':
    unittest.main()
