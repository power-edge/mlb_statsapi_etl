"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpointModel
from ..utils import api_path


class ConferenceModel(MLBStatsAPIEndpointModel):

    @api_path("/v1/conferences")
    def conferences(self, **kwargs):
        return self.get_api_file_object(**kwargs)
