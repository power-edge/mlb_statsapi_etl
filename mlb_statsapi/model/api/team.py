"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpointModel
from ..utils import api_path


class TeamModel(MLBStatsAPIEndpointModel):

    @api_path("/v1/teams")
    def teams(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/teams/affiliates")
    def affiliates(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/teams/history")
    def allTeams(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/teams/stats")
    def stats(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/teams/stats/leaders", name="leaders")
    def statsLeaders(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/teams/{teamId}/affiliates", name='affiliates')
    def teamAffiliates(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/teams/{teamId}/alumni")
    def alumni(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/teams/{teamId}/alumni")
    def updateAlumni(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/teams/{teamId}/coaches")
    def coaches(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/teams/{teamId}/history", name="allTeams")
    def history(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/teams/{teamId}/leaders")
    def leaders(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/teams/{teamId}/roster/{rosterType}")
    def roster(self, **kwargs):
        return self.get_api_file_object(**kwargs)
