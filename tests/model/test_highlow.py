"""
created by nikos at 4/29/21
"""
import unittest

from .base_test_mixin import ModelTestMixin, sleep_after_get


class TestHighLowModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.highlow import HighLowModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)

    @sleep_after_get()
    def test_get_highLowStats(self):
        with self.assertRaises(AssertionError):
            self.api_doc.highLowStats(path_params={'game_pk': 12345})
        fo = self.api_doc.highLowStats()
        self.dump(fo.get().obj)

    @sleep_after_get()
    def test_get_highLow(self):
        with self.assertRaises(AssertionError):
            self.api_doc.highLow()
        with self.assertRaises(AssertionError):
            self.api_doc.highLow(path_params={'highLowType': "UNRECOGNIZED_CHOICE_RAISES_ASSERTION_ERROR"})
        fo = self.api_doc.highLow(path_params={'highLowType': "game"})  # json configs have all-caps enums, pass lower
        self.dump(fo.get().obj)


if __name__ == '__main__':
    unittest.main()
