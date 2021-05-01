"""
created by nikos at 4/29/21
"""
import unittest

from .base_test_mixin import ModelTestMixin, sleep_after_get


class TestSportsModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.sports import SportsModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)

    @sleep_after_get()
    def test_get_sportPlayers(self):
        self.dump(self.api_doc.sportPlayers(
            path_params={'sportId': 1},
            query_params={
                'season': 2020,
                'gameType': 'r',
                'hasStats': 'true',
            }
        ).get().obj)


if __name__ == '__main__':
    unittest.main()
