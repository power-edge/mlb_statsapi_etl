"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpoint
from ..utils import api_path


class SportsModel(MLBStatsAPIEndpoint):

    @api_path("/v1/sports/{sportId}/players")
    def sportPlayers(self, **kwargs):
        return self.get(**kwargs)
