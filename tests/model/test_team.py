"""
created by nikos at 4/29/21
"""
import unittest

from .base_test_mixin import ModelTestMixin


class TestTeamModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.team import TeamModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)


if __name__ == '__main__':
    unittest.main()
