"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpoint
from ..utils import api_path


class SeasonModel(MLBStatsAPIEndpoint):

    @api_path("/v1/seasons")
    def seasons(self, **kwargs):
        return self.get(**kwargs)

    @api_path("/v1/seasons/all")
    def allSeasons(self, **kwargs):
        return self.get(**kwargs)

    @api_path("/v1/seasons/{seasonId}", name="seasons")
    def season(self, **kwargs):
        return self.get(**kwargs)
