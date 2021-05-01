"""
created by nikos at 4/29/21
"""
import unittest

from .base_test_mixin import ModelTestMixin, sleep_after_get


class TestLeagueModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.league import LeagueModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)

    @sleep_after_get()
    def test_get_allStarFinalVote(self):
        fo = self.api_doc.allStarFinalVote(
            path_params={'leagueId': "104"},  # NL
            query_params={"season": 2017}
        )
        self.dump(fo.get().obj)

    @sleep_after_get()
    def test_get_allStarWriteIns(self):
        fo = self.api_doc.allStarWriteIns(
            path_params={'leagueId': "103"},  # AL
            query_params={"season": 2017}
        )
        self.dump(fo.get().obj)

    @sleep_after_get()
    def test_get_allStarsFinalVote(self):
        fo = self.api_doc.allStarsFinalVote(
            path_params={'leagueId': "104"},  # NL
            query_params={"season": 2017}
        )
        self.dump(fo.get().obj)

    @sleep_after_get()
    def test_get_allStarsWriteIns(self):
        fo = self.api_doc.allStarsFinalVote(
            path_params={'leagueId': "104"},  # NL
            query_params={"season": 2017}
        )
        self.dump(fo.get().obj)


if __name__ == '__main__':
    unittest.main()
