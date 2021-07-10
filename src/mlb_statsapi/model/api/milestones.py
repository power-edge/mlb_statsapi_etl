"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpointModel
from mlb_statsapi.utils.stats_api_object import configure_api


class MilestonesModel(MLBStatsAPIEndpointModel):

    @configure_api
    def achievementStatuses(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def milestoneDurations(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def milestoneLookups(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def milestoneStatistics(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def milestoneTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def milestones(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    _methods = {m.__name__: m for m in (
        achievementStatuses,
        milestoneDurations,
        milestoneLookups,
        milestoneStatistics,
        milestoneTypes,
        milestones
    )}