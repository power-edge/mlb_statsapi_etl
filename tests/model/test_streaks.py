"""
created by nikos at 4/29/21
"""
import unittest

from .base_test_mixin import ModelTestMixin, sleep_after_get


class TestStreaksModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.streaks import StreaksModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)

    @sleep_after_get()
    def test_get_getStreaks(self):
        self.dump(self.api_doc.getStreaks(query_params={
            'streakOrg': 'team'
        }).get().obj)

    @sleep_after_get()
    def test_get_highLowStats(self):
        self.dump(self.api_doc.highLowStats().get().obj)


if __name__ == '__main__':
    unittest.main()
