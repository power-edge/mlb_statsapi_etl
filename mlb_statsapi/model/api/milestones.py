"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpointModel
from ..utils import api_path


class MilestonesModel(MLBStatsAPIEndpointModel):

    @api_path("/v1/achievementStatuses")
    def achievementStatuses(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/milestoneDurations")
    def milestoneDurations(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/milestoneLookups")
    def milestoneLookups(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/milestoneStatistics")
    def milestoneStatistics(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/milestoneTypes")
    def milestoneTypes(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/milestones")
    def milestones(self, **kwargs):
        return self.get_api_file_object(**kwargs)