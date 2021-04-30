"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpointModel
from ..utils import api_path


class SeasonModel(MLBStatsAPIEndpointModel):

    @api_path("/v1/seasons")
    def seasons(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/seasons/all")
    def allSeasons(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/seasons/{seasonId}", name="seasons")
    def season(self, **kwargs):
        return self.get_api_file_object(**kwargs)
