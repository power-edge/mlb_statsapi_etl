"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpoint
from ..utils import api_path


class JobModel(MLBStatsAPIEndpoint):

    @api_path("/v1/jobs")
    def getJobsByType(self, **kwargs):
        return self.get(**kwargs)

    @api_path("/v1/jobs/datacasters")
    def datacasters(self, **kwargs):
        return self.get(**kwargs)

    @api_path("/v1/jobs/officialScorers")
    def officialScorers(self, **kwargs):
        return self.get(**kwargs)

    @api_path("/v1/jobs/umpires")
    def umpires(self, **kwargs):
        return self.get(**kwargs)
