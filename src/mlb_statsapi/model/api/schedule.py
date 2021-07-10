"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpointModel
from mlb_statsapi.utils.stats_api_object import configure_api


class ScheduleModel(MLBStatsAPIEndpointModel):

    @configure_api
    def schedule(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def tieGames(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def postseasonScheduleSeries(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def tuneIn(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def scheduleType(self, **kwargs):
        if kwargs:
            raise NotImplementedError("this beta statsapi docs is buggy: will not allow you to pass the scheduleType!")
        return self.get_api_file_object(**kwargs)

    _methods = {m.__name__: m for m in (
        schedule,
        tieGames,
        postseasonScheduleSeries,
        tuneIn,
        scheduleType
    )}