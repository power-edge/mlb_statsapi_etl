"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpointModel
from mlb_statsapi.utils.stats_api_object import configure_api


class AwardsModel(MLBStatsAPIEndpointModel):

    @configure_api
    def awards(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def awardRecipients(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    _methods = {m.__name__: m for m in (
        awards,
        awardRecipients
    )}

    def run(self, **kwargs):
        pass
