"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpoint
from ..utils import api_path


class DivisionModel(MLBStatsAPIEndpoint):

    @api_path("/v1/divisions")
    def divisions(self, **kwargs):
        return self.get(**kwargs)
