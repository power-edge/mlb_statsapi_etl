"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpoint
from ..utils import api_path


class PersonModel(MLBStatsAPIEndpoint):

    @api_path("/v1/people")
    def person(self, **kwargs):
        return self.get(**kwargs)

    @api_path("/v1/people/changes", name="currentGameStats")
    def changes(self, **kwargs):
        return self.get(**kwargs)

    @api_path("/v1/people/freeAgents")
    def freeAgents(self, **kwargs):
        return self.get(**kwargs)

    @api_path("/v1/people/{personId}/awards")
    def award(self, **kwargs):
        return self.get(**kwargs)

    @api_path("/v1/people/{personId}/stats/game/current")
    def currentGameStats(self, **kwargs):
        return self.get(**kwargs)

    @api_path("/v1/people/{personId}/stats/game/{gamePk}", name="currentGameStats")
    def gameStats(self, **kwargs):
        return self.get(**kwargs)
