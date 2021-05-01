"""
created by nikos at 4/29/21
"""
import unittest

from .base_test_mixin import ModelTestMixin, sleep_after_get


class TestSeasonModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.season import SeasonModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)

    # def test_get_seasons(self):
    #     self.dump(self.api_doc.seasons(
    #         path_params={'seasonId': '2012'},
    #         query_params={'sportId': 1}
    #     ).get().obj)

    @sleep_after_get()
    def test_get_allSeasons(self):
        self.dump(self.api_doc.allSeasons(
            query_params={'sportId': 1}
        ).get().obj)

    @sleep_after_get()
    def test_get_season(self):
        self.dump(self.api_doc.season(
            path_params={'seasonId': 2017},
            query_params={'sportId': 1}
        ).get().obj)


if __name__ == '__main__':
    unittest.main()
