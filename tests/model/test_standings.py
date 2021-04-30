"""
created by nikos at 4/29/21
"""
import unittest

from .base_test_mixin import ModelTestMixin


class TestStandingsModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.standings import StandingsModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)


if __name__ == '__main__':
    unittest.main()
