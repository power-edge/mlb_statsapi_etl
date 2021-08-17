"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpointModel
from mlb_statsapi.utils.stats_api_object import configure_api


class BroadcastModel(MLBStatsAPIEndpointModel):

    @configure_api
    def getBroadcasts(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @property
    def _methods(self): return {m.__name__: m for m in (
        self.getBroadcasts,
    )}

