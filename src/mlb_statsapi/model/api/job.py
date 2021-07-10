"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpointModel
from mlb_statsapi.utils.stats_api_object import configure_api


class JobModel(MLBStatsAPIEndpointModel):

    @configure_api
    def getJobsByType(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def datacasters(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def officialScorers(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def umpires(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    _methods = {m.__name__: m for m in (
        getJobsByType,
        datacasters,
        officialScorers,
        umpires
    )}