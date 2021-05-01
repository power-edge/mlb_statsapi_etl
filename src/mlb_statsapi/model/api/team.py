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
        # return self.get_api_file_object(**kwargs)
        raise NotImplementedError("""TODO - fix https://beta-statsapi.mlb.com/api/api_docs/stats-api/team affiliates api
        Problem: beta statsapi has incorrectly defined the path of the affiliates endpoint
            teamId (sh|w)ould be inserted per the standard pattern of teams/{teamId}/affiliates, but the affiliates api
            "path": "/v1/teams/affiliates" will always return `HTTP Status 404 – Not Found`
        Reproduce: https://statsapi.mlb.com/api/v1/teams/affiliates/147?sportId=1 is 404
           whereas https://statsapi.mlb.com/api/v1/teams/147/affiliates?sportId=1 does return the payload
        Note: teamId as a query_param does not work either.
        """)

    @api_path("/v1/teams/history")
    def allTeams(self, **kwargs):
        """Nonfunctional and duplicated: This same data is available on a teamId basis at the history() api"""
        # return self.get_api_file_object(**kwargs)
        raise NotImplementedError("""TODO - fix https://beta-statsapi.mlb.com/api/api_docs/stats-api/team allTeams` api
                Problem: beta statsapi has incorrectly defined the path of the allTeams endpoint
                    teamId (sh|w)ould be inserted per the standard pattern of teams/{teamId}/affiliates, but the affiliates api
                    "path": "/v1/teams/affiliates" will always return `HTTP Status 404 – Not Found`
                Reproduce: https://statsapi.mlb.com/api/v1/teams/history/147?sportId=1 is 404
                   whereas https://statsapi.mlb.com/api/v1/teams/147/history?sportId=1 does return the payload
        Note: teamId as a query_param does not work either.
                """)

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
