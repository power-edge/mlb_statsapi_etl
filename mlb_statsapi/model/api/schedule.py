"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpoint
from ..utils import api_path


class ScheduleModel(MLBStatsAPIEndpoint):

    @api_path("/v1/schedule")
    def schedule(self, **kwargs):
        return self.get(**kwargs)

    @api_path("/v1/schedule/games/tied")
    def tieGames(self, **kwargs):
        return self.get(**kwargs)

    @api_path("/v1/schedule/postseason/series")
    def postseasonScheduleSeries(self, **kwargs):
        return self.get(**kwargs)

    @api_path("/v1/schedule/postseason/tuneIn")
    def tuneIn(self, **kwargs):
        return self.get(**kwargs)

    @api_path("/v1/schedule/{scheduleType}", name="schedule")
    def scheduleType(self, **kwargs):
        return self.get(**kwargs)
