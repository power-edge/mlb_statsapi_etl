"""
created by nikos at 4/26/21
"""
import os.path

from ..base import MLBStatsAPIEndpointModel
from mlb_statsapi.utils.stats_api_object import configure_api


class ConfigModel(MLBStatsAPIEndpointModel):

    @configure_api
    def awards(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def baseballStats(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def eventTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def fielderDetailTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def gameStatus(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def gameTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def gamedayTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def groupByTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def hitTrajectories(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def jobTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def languages(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def leagueLeaderTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def logicalEvents(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def metrics(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def pitchCodes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def pitchTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def platforms(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def playerStatusCodes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def positions(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def reviewReasons(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def rosterTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def runnerDetailTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def scheduleEventTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def sitCodes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def sky(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def aggregateSortEnum(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def standingsTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def statFields(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def statGroups(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def statTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def statSearchConfig(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def statSearchGroupByTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def statSearchParams(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def statSearchStats(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def transactionTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def windDirection(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @property
    def _methods(self): return {m.__name__: m for m in (
        self.awards,
        self.baseballStats,
        self.eventTypes,
        self.fielderDetailTypes,
        self.gameStatus,
        self.gameTypes,
        self.gamedayTypes,
        self.groupByTypes,
        self.hitTrajectories,
        self.jobTypes,
        self.languages,
        self.leagueLeaderTypes,
        self.logicalEvents,
        self.metrics,
        self.pitchCodes,
        self.pitchTypes,
        self.platforms,
        self.playerStatusCodes,
        self.positions,
        self.reviewReasons,
        self.rosterTypes,
        self.runnerDetailTypes,
        self.scheduleEventTypes,
        self.sitCodes,
        self.sky,
        self.aggregateSortEnum,
        self.standingsTypes,
        self.statFields,
        self.statGroups,
        self.statTypes,
        self.statSearchConfig,
        self.statSearchGroupByTypes,
        self.statSearchParams,
        self.statSearchStats,
        self.transactionTypes,
        self.windDirection,
    )}
