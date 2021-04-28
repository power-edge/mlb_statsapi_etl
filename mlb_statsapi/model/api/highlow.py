"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpoint
from ..utils import api_path


class HighLowModel(MLBStatsAPIEndpoint):

    @api_path("/v1/highLow/types")
    def highLowStats(self, **kwargs):
        return self.get(**kwargs)

    @api_path("/v1/highLow/{highLowType}")
    def highLow(self, **kwargs):
        return self.get(**kwargs)

