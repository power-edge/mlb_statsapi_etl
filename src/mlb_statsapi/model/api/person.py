
"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpointModel
from ..utils import api_path

Y_M_D = '%Y-%m-%d'
YMDTHMS = '%Y-%m-%dT%H:%M:%SZ'
YYYYMMDD_HHMMSS = '%Y%m%d_%H%M%S'
MMDDYYYY_HHMMSS = '%m%d%Y_%H%M%S'


class PersonModel(MLBStatsAPIEndpointModel):

    date_formats = {'updatedSince': YMDTHMS}

    @api_path("/v1/people")
    def person(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/people/changes", name="currentGameStats")
    def changes(self, **kwargs):
        """badly misnamed in the api_docs^ +this duplicates the api.description or api.operations[].nickname space"""
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/people/freeAgents")
    def freeAgents(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/people/{personId}/awards")
    def award(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/people/{personId}/stats/game/current")
    def currentGameStats(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/people/{personId}/stats/game/{gamePk}", name="currentGameStats")
    def gameStats(self, **kwargs):
        """also duplicates the api.description or api.operations[].nickname space"""
        return self.get_api_file_object(**kwargs)
