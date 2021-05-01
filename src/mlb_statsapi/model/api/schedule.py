"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpointModel
from ..utils import api_path


class ScheduleModel(MLBStatsAPIEndpointModel):

    @api_path("/v1/schedule")
    def schedule(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/schedule/games/tied")
    def tieGames(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/schedule/postseason/series")
    def postseasonScheduleSeries(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/schedule/postseason/tuneIn")
    def tuneIn(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/schedule/{scheduleType}", name="schedule")
    def scheduleType(self, **kwargs):
        if kwargs:
            raise NotImplementedError("this beta statsapi docs is buggy: will not allow you to pass the scheduleType!")
        return self.get_api_file_object(**kwargs)
