"""
created by nikos at 4/29/21
"""
import unittest

from .base_test_mixin import ModelTestMixin, sleep_after_get


class TestJobModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.job import JobModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)

    @sleep_after_get()
    def test_get_getJobsByType(self):
        fo = self.api_doc.getJobsByType(query_params={'jobType': "UMPR", "sportId": 1})
        self.dump(fo.get().obj)

    @sleep_after_get()
    def test_get_datacasters(self):
        fo = self.api_doc.datacasters(query_params={'date': "2021-04-15", "sportId": 1})
        self.dump(fo.get().obj)

    @sleep_after_get()
    def test_get_officialScorers(self):
        fo = self.api_doc.officialScorers(query_params={'date': "2021-04-15", "sportId": 1})
        self.dump(fo.get().obj)

    @sleep_after_get()
    def test_get_umpires(self):
        fo = self.api_doc.umpires(query_params={'date': "2021-04-15", "sportId": 1})
        self.dump(fo.get().obj)


if __name__ == '__main__':
    unittest.main()
