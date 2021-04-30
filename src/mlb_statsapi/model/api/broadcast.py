"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpointModel
from ..utils import api_path


class BroadcastModel(MLBStatsAPIEndpointModel):

    @api_path("/v1/broadcast")
    def getBroadcasts(self, **kwargs):
        return self.get_api_file_object(**kwargs)
