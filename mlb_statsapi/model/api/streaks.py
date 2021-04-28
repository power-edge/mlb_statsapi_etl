"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpoint
from ..utils import api_path


class StreaksModel(MLBStatsAPIEndpoint):

    @api_path("/v1/streaks")
    def getStreaks(self, **kwargs):
        return self.get(**kwargs)

    @api_path("/v1/streaks/types")
    def highLowStats(self, **kwargs):
        return self.get(**kwargs)
