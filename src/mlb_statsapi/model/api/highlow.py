"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpointModel
from mlb_statsapi.utils.stats_api_object import configure_api


class HighLowModel(MLBStatsAPIEndpointModel):


    @configure_api
    def highLow(self, **kwargs):
        return self.get_api_file_object(**kwargs)


    @configure_api
    def highLowStats(self, **kwargs):
        return self.get_api_file_object(**kwargs)


    _methods = {m.__name__: m for m in (
        highLow,
        highLowStats
    )}
