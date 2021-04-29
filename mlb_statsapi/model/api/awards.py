"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpointModel
from ..utils import api_path


class AwardsModel(MLBStatsAPIEndpointModel):

    @api_path("/v1/awards/{awardId}")
    def awards(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/awards/{awardId}/recipients")
    def awardRecipients(self, **kwargs):
        return self.get_api_file_object(**kwargs)
