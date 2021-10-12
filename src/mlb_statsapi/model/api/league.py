"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpointModel
from mlb_statsapi.utils.stats_api_object import configure_api


class LeagueModel(MLBStatsAPIEndpointModel):

    @configure_api
    def allStarFinalVote(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def allStarWriteIns(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def allStarsFinalVote(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def allStarsWriteIns(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @property
    def _methods(self) -> dict: return {m.__name__: m for m in (
        self.allStarFinalVote,
        self.allStarWriteIns,
        self.allStarsFinalVote,
        self.allStarsWriteIns
    )}