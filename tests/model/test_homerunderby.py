"""
created by nikos at 4/29/21
"""
import unittest

from .base_test_mixin import ModelTestMixin


class TestHomeRunDerbyModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.homerunderby import HomeRunDerbyModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)

    def test_get_homeRunDerby(self):
        pass

    def test_get_homeRunDerbyBracket(self):
        pass

    def test_get_homeRunDerbyPool(self):
        pass

    def test_get_homeRunDerbyGameBracket(self):
        pass

    def test_get_homeRunDerbyGamePool(self):
        pass


if __name__ == '__main__':
    unittest.main()
