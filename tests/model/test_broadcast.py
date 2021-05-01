"""
created by nikos at 4/29/21
"""
import unittest

from .base_test_mixin import ModelTestMixin, sleep_after_get


class TestBroadcastModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.broadcast import BroadcastModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)

    @sleep_after_get()
    def test_get_getBroadcasts(self):  # TODO
        with self.assertRaises(AssertionError):
            self.api_doc.getBroadcasts()
        with self.assertRaises(AssertionError):
            self.api_doc.getBroadcasts(path_params={'broadcasterIds': [12345, ]})
        broadcasts = self.api_doc.getBroadcasts(query_params={'broadcasterIds': [12345, ]})
        self.dump(broadcasts.get().obj)


if __name__ == '__main__':
    unittest.main()
