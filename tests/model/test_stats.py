"""
created by nikos at 4/29/21
"""
import unittest

from .base_test_mixin import ModelTestMixin, sleep_after_get


class TestStatsModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.stats import StatsModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)

    @sleep_after_get()
    def test_get_stats(self):
        self.dump(self.api_doc.stats(
            query_params={
                'stats': 'career',
                'group': 'pitching',
                'gameType': 'regularSeason',
                'personId': 596295,
            }
        ).get().obj)

    @sleep_after_get()
    def test_get_groupedStats(self):
        self.dump(self.api_doc.groupedStats(
            query_params={
                'stats': 'season',
                'group': 'hitting',
                'teamId': 147,
            }
        ).get().obj)

    @sleep_after_get()
    def test_get_leaders(self):
        """unable to get a response with .leagueLeaders"""
        self.dump(self.api_doc.leaders(
            query_params={
                'statGroup': 'hitting',
                'season': 2020,
                'sportId': 1,
                'stats': 'season',
                'teamId': 147
            }
        ).get().obj)


if __name__ == '__main__':
    unittest.main()
