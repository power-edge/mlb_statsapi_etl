"""
created by nikos at 4/29/21
"""
import unittest

from .base_test_mixin import ModelTestMixin


class TestSeasonModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.season import SeasonModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)

    def test_get_seasons(self):
        self.dump(self.api_doc.seasons(
            path_params={'seasonId': 1}
        ).get().obj)

    def test_get_allSeasons(self):
        self.dump(self.api_doc.allSeasons(

        ).get().obj)

    def test_get_season(self):
        self.dump(self.api_doc.season(

        ).get().obj)


if __name__ == '__main__':
    unittest.main()
