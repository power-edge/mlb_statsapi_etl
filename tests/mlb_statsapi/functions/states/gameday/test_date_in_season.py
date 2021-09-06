"""
created by nikos at 9/3/21
"""
import json
import os
from tests.mlb_statsapi.functions import LambdaTestCase
import unittest


class TestDateInSeason(LambdaTestCase):

    def test_date_has_games(self):
        self.lambda_module.date_has_games(self.StatsAPI.Schedule.schedule, self.event["date"])

    def test_date_in_season(self):
        self.lambda_module.date_in_season(self.StatsAPI.Season.season, self.event)


if __name__ == '__main__':
    unittest.main()
