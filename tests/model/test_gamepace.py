"""
created by nikos at 4/29/21

Note - Gamepace endpoint does nothing it seems ? so don't worry about it
"""
import unittest

from .base_test_mixin import ModelTestMixin


class TestGamepaceModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.gamepace import GamepaceModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)


if __name__ == '__main__':
    unittest.main()
