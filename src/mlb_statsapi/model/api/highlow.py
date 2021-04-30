"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpointModel
from ..utils import api_path


class HighLowModel(MLBStatsAPIEndpointModel):

    @api_path("/v1/highLow/types")
    def highLowStats(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/highLow/{highLowType}")
    def highLow(self, **kwargs):
        return self.get_api_file_object(**kwargs)

