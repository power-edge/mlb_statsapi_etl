"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpointModel
from ..utils import api_path


class StatsModel(MLBStatsAPIEndpointModel):

    @api_path("/v1/stats")
    def stats(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/stats/grouped")
    def groupedStats(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/stats/leaders")
    def leaders(self, **kwargs):
        return self.get_api_file_object(**kwargs)
