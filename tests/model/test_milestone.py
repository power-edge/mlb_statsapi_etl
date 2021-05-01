"""
created by nikos at 4/29/21
"""
import unittest

from .base_test_mixin import ModelTestMixin, sleep_after_get


class TestMilestonesModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.milestones import MilestonesModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)

    @sleep_after_get()
    def test_get_achievementStatuses(self):
        fo = self.api_doc.achievementStatuses()
        self.dump(fo.get().obj)

    @sleep_after_get()
    def test_get_milestoneDurations(self):
        fo = self.api_doc.milestoneDurations()
        self.dump(fo.get().obj)

    @sleep_after_get()
    def test_get_milestoneLookups(self):
        fo = self.api_doc.milestoneLookups()
        self.dump(fo.get().obj)

    # def test_get_milestoneStatistics(self):
    #     fo = self.api_doc.milestoneStatistics()
    #     self.dump(fo.get().obj)

    @sleep_after_get()
    def test_get_milestoneTypes(self):
        fo = self.api_doc.milestoneTypes()
        self.dump(fo.get().obj)

    # def test_get_milestones(self):
    #     """
    #     {"messageNumber":13,"message":"Operation taking longer than expected - please try again"}
    #     """
    #     fo = self.api_doc.milestones()
    #     self.dump(fo.get().obj)
    #     fo_ply = self.api_doc.milestones(query_params={
    #         "orgType": "player",
    #         "milestoneTypes": "C",
    #         "teamIds": 104,
    #         "statGroup": "hitting",
    #         "seasons": 2019
    #     })
    #     self.dump(fo_ply.get().obj)


if __name__ == '__main__':
    unittest.main()
