"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpointModel
from mlb_statsapi.utils.stats_api_object import configure_api


class StatsModel(MLBStatsAPIEndpointModel):

    @configure_api
    def groupedStats(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def leaders(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def stats(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @property
    def _methods(self) -> dict: return {m.__name__: m for m in (
        self.groupedStats,
        self.leaders,
        self.stats
    )}