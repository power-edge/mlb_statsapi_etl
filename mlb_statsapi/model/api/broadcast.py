"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpoint
from ..utils import api_path


class BroadcastModel(MLBStatsAPIEndpoint):

    @api_path("/v1/broadcast")
    def getBroadcasts(self, **kwargs):
        return self.get(**kwargs)
