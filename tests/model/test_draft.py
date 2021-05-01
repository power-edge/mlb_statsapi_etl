"""
created by nikos at 4/29/21
"""
import unittest

from .base_test_mixin import ModelTestMixin, sleep_after_get


class TestDraftModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.draft import DraftModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)

    @sleep_after_get()
    def test_get_draftPicks(self):
        with self.assertRaises(AssertionError):
            self.api_doc.draftPicks()
        # this returns a huge payload, skipping
        # fo = self.api_doc.draftPicks(path_params={'year': 2015}, query_params={'limit': 1})
        # self.dump(fo.get().obj)

    @sleep_after_get()
    def test_get_draftProspects(self):
        with self.assertRaises(AssertionError):
            self.api_doc.draftPicks()
        fo = self.api_doc.draftProspects(path_params={'year': 2018}, query_params={'limit': 1})
        self.dump(fo.get().obj)

    # takes quite a long time to query
    # @sleep_after_get()
    # def test_get_latestDraftPicks(self):
    #     with self.assertRaises(AssertionError):
    #         self.api_doc.latestDraftPicks()
    #     fo = self.api_doc.latestDraftPicks(path_params={'year': 2018})
    #     self.dump(fo.get().obj)


if __name__ == '__main__':
    unittest.main()
