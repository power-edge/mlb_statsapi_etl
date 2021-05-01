"""
created by nikos at 4/29/21

TODO: Search the schedule for a home run derby day and determine a game_pk for a homeRunDerbyBracket!
"""
import unittest

from .base_test_mixin import ModelTestMixin, sleep_after_get


class TestHomeRunDerbyModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.homerunderby import HomeRunDerbyModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)

    # @sleep_after_get()
    def test_get_homeRunDerby(self):
        pass

    # @sleep_after_get()
    def test_get_homeRunDerbyBracket(self):
        pass

    # @sleep_after_get()
    def test_get_homeRunDerbyPool(self):
        pass

    # @sleep_after_get()
    def test_get_homeRunDerbyGameBracket(self):
        pass

    # @sleep_after_get()
    def test_get_homeRunDerbyGamePool(self):
        pass


if __name__ == '__main__':
    unittest.main()
