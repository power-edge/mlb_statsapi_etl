"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpointModel
from ..utils import api_path


class LeagueModel(MLBStatsAPIEndpointModel):

    @api_path("/v1/league/{leagueId}/allStarFinalVote")
    def allStarFinalVote(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/league/{leagueId}/allStarWriteIns")
    def allStarWriteIns(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/leagues/{leagueId}/allStarFinalVote", name="allStarFinalVote")
    def allStarsFinalVote(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/leagues/{leagueId}/allStarWriteIns", name="allStarWriteIns")
    def allStarsWriteIns(self, **kwargs):
        return self.get_api_file_object(**kwargs)