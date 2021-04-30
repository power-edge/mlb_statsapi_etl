"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpointModel
from ..utils import api_path


class DivisionModel(MLBStatsAPIEndpointModel):

    @api_path("/v1/divisions")
    def divisions(self, **kwargs):
        return self.get_api_file_object(**kwargs)
