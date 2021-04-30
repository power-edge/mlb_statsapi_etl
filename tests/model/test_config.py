"""
created by nikos at 4/29/21
"""
import unittest

from .base_test_mixin import ModelTestMixin


class TestConfigModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.config import ConfigModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)

    def test_get_baseballStats(self):
        fo = self.api_doc.baseballStats()
        self.dump(fo.get().obj)

    def test_get_eventTypes(self):
        fo = self.api_doc.eventTypes()
        self.dump(fo.get().obj)

    def test_get_fielderDetailTypes(self):
        fo = self.api_doc.fielderDetailTypes()
        self.dump(fo.get().obj)

    def test_get_gameStatus(self):
        fo = self.api_doc.gameStatus()
        self.dump(fo.get().obj)

    def test_get_gameTypes(self):
        fo = self.api_doc.gameTypes()
        self.dump(fo.get().obj)

    def test_get_gamedayTypes(self):
        fo = self.api_doc.gamedayTypes()
        self.dump(fo.get().obj)

    def test_get_groupByTypes(self):
        fo = self.api_doc.groupByTypes()
        self.dump(fo.get().obj)

    def test_get_hitTrajectories(self):
        fo = self.api_doc.hitTrajectories()
        self.dump(fo.get().obj)

    def test_get_jobTypes(self):
        fo = self.api_doc.jobTypes()
        self.dump(fo.get().obj)

    def test_get_languages(self):
        fo = self.api_doc.languages()
        self.dump(fo.get().obj)

    def test_get_leagueLeaderTypes(self):
        fo = self.api_doc.leagueLeaderTypes()
        self.dump(fo.get().obj)

    def test_get_logicalEvents(self):
        fo = self.api_doc.logicalEvents()
        self.dump(fo.get().obj)

    def test_get_metrics(self):
        fo = self.api_doc.metrics()
        self.dump(fo.get().obj)

    def test_get_pitchCodes(self):
        fo = self.api_doc.pitchCodes()
        self.dump(fo.get().obj)

    def test_get_pitchTypes(self):
        fo = self.api_doc.pitchTypes()
        self.dump(fo.get().obj)

    def test_get_platforms(self):
        fo = self.api_doc.platforms()
        self.dump(fo.get().obj)

    def test_get_playerStatusCodes(self):
        fo = self.api_doc.playerStatusCodes()
        self.dump(fo.get().obj)

    def test_get_positions(self):
        fo = self.api_doc.positions()
        self.dump(fo.get().obj)

    def test_get_reviewReasons(self):
        fo = self.api_doc.reviewReasons()
        self.dump(fo.get().obj)

    def test_get_rosterTypes(self):
        fo = self.api_doc.rosterTypes()
        self.dump(fo.get().obj)

    def test_get_runnerDetailTypes(self):
        fo = self.api_doc.runnerDetailTypes()
        self.dump(fo.get().obj)

    def test_get_scheduleEventTypes(self):
        fo = self.api_doc.scheduleEventTypes()
        self.dump(fo.get().obj)

    def test_get_sitCodes(self):
        fo = self.api_doc.sitCodes()
        self.dump(fo.get().obj)

    def test_get_sky(self):
        fo = self.api_doc.sky()
        self.dump(fo.get().obj)

    def test_get_aggregateSortEnum(self):
        fo = self.api_doc.aggregateSortEnum()
        self.dump(fo.get().obj)

    def test_get_standingsTypes(self):
        fo = self.api_doc.standingsTypes()
        self.dump(fo.get().obj)

    def test_get_statFields(self):
        fo = self.api_doc.statFields()
        self.dump(fo.get().obj)

    def test_get_statGroups(self):
        fo = self.api_doc.statGroups()
        self.dump(fo.get().obj)

    def test_get_statTypes(self):
        fo = self.api_doc.statTypes()
        self.dump(fo.get().obj)

    def test_get_statSearchConfig(self):
        fo = self.api_doc.statSearchConfig()
        self.dump(fo.get().obj)

    def test_get_statSearchGroupByTypes(self):
        fo = self.api_doc.statSearchGroupByTypes()
        self.dump(fo.get().obj)

    def test_get_statSearchParams(self):
        fo = self.api_doc.statSearchParams()
        self.dump(fo.get().obj)

    def test_get_statSearchStats(self):
        fo = self.api_doc.statSearchStats()
        self.dump(fo.get().obj)

    def test_get_transactionTypes(self):
        fo = self.api_doc.transactionTypes()
        self.dump(fo.get().obj)

    def test_get_windDirection(self):
        fo = self.api_doc.windDirection()
        self.dump(fo.get().obj)

    def test_get_awards(self):
        fo = self.api_doc.awards()
        self.dump(fo.get().obj)


if __name__ == '__main__':
    unittest.main()
