"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpoint
from ..utils import api_path


class AwardsModel(MLBStatsAPIEndpoint):

    @api_path("/v1/awards/{awardId}")
    def awards(self, **kwargs):
        return self.get(**kwargs)

    @api_path("/v1/awards/{awardId}/recipients")
    def awardRecipients(self, **kwargs):
        return self.get(**kwargs)
