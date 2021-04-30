"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpointModel
from ..utils import api_path


class JobModel(MLBStatsAPIEndpointModel):

    @api_path("/v1/jobs")
    def getJobsByType(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/jobs/datacasters")
    def datacasters(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/jobs/officialScorers")
    def officialScorers(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/jobs/umpires")
    def umpires(self, **kwargs):
        return self.get_api_file_object(**kwargs)
