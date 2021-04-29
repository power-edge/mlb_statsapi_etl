"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpointModel
from ..utils import api_path


class StreaksModel(MLBStatsAPIEndpointModel):

    @api_path("/v1/streaks")
    def getStreaks(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/streaks/types")
    def highLowStats(self, **kwargs):
        return self.get_api_file_object(**kwargs)
