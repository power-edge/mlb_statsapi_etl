"""
created by nikos at 4/29/21
"""
import unittest

from .base_test_mixin import ModelTestMixin, sleep_after_get


class TestStandingsModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.standings import StandingsModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)

    @sleep_after_get()
    def test_get_standings(self):
        """some of the query params result in internal errors"""
        self.dump(self.api_doc.standings(
            path_params={'standingsType': 'regularSeason'},
            query_params={
                'leagueId': '104',
                'season': '2020'
            }
        ).get().obj)


if __name__ == '__main__':
    unittest.main()
