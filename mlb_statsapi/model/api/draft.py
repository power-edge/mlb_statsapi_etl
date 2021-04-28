"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpoint
from ..utils import api_path


class DraftModel(MLBStatsAPIEndpoint):

    @api_path("/v1/draft")
    def draftPicks(self, **kwargs):
        return self.get(**kwargs)

    @api_path("/v1/draft/prospects/{year}")
    def draftProspects(self, **kwargs):
        return self.get(**kwargs)

    @api_path("/v1/draft/{year}/latest")
    def latestDraftPicks(self, **kwargs):
        return self.get(**kwargs)
