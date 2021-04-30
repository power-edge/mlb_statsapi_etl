"""
created by nikos at 4/29/21
"""
import unittest

from .base_test_mixin import ModelTestMixin


class TestStatsModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.stats import StatsModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)


if __name__ == '__main__':
    unittest.main()
