"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpoint
from ..utils import api_path


class ConferenceModel(MLBStatsAPIEndpoint):

    @api_path("/v1/conferences")
    def conferences(self, **kwargs):
        return self.get(**kwargs)
