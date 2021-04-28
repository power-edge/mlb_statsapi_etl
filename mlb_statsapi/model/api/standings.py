"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpoint
from ..utils import api_path


class StandingsModel(MLBStatsAPIEndpoint):

    @api_path("/v1/standings/{standingsType}")
    def standings(self, **kwargs):
        return self.get(**kwargs)

