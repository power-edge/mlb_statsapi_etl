"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpointModel
from ..utils import api_path


class ConfigModel(MLBStatsAPIEndpointModel):

    @api_path("/v1/awards")
    def awards(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/baseballStats")
    def baseballStats(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/eventTypes")
    def eventTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/fielderDetailTypes")
    def fielderDetailTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/gameStatus")
    def gameStatus(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/gameTypes")
    def gameTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/gamedayTypes")
    def gamedayTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/groupByTypes")
    def groupByTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/hitTrajectories")
    def hitTrajectories(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/jobTypes")
    def jobTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/languages")
    def languages(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/leagueLeaderTypes")
    def leagueLeaderTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/logicalEvents")
    def logicalEvents(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/metrics")
    def metrics(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/pitchCodes")
    def pitchCodes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/pitchTypes")
    def pitchTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/platforms")
    def platforms(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/playerStatusCodes")
    def playerStatusCodes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/positions")
    def positions(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/reviewReasons")
    def reviewReasons(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/rosterTypes")
    def rosterTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/runnerDetailTypes")
    def runnerDetailTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/scheduleEventTypes")
    def scheduleEventTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/situationCodes")
    def sitCodes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/sky")
    def sky(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/sortModifiers")
    def aggregateSortEnum(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/standingsTypes")
    def standingsTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/statFields")
    def statFields(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/statGroups")
    def statGroups(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/statTypes")
    def statTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/stats/search/config")
    def statSearchConfig(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/stats/search/groupByTypes")
    def statSearchGroupByTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/stats/search/params")
    def statSearchParams(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/stats/search/stats")
    def statSearchStats(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/transactionTypes")
    def transactionTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/windDirection")
    def windDirection(self, **kwargs):
        return self.get_api_file_object(**kwargs)
