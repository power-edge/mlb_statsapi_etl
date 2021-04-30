"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpointModel
from ..utils import api_path


YMDTHMS = '%Y-%m-%dT%H:%M:%SZ'
YYYYMMDD_HHMMSS = '%Y%m%d_%H%M%S'
MMDDYYYY_HHMMSS = '%m%d%Y_%H%M%S'


class GameModel(MLBStatsAPIEndpointModel):

    date_formats = {
        'updatedSince': YMDTHMS,
        'timecode': YYYYMMDD_HHMMSS,
        'startTimecode': MMDDYYYY_HHMMSS,
        'endTimecode': MMDDYYYY_HHMMSS
    }

    @api_path("/v1.1/game/{game_pk}/feed/live")
    def liveGameV1(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1.1/game/{game_pk}/feed/live/diffPatch")
    def liveGameDiffPatchV1(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1.1/game/{game_pk}/feed/live/timestamps")
    def liveTimestampv11(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/game/changes")
    def currentGameStats(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/game/{gamePk}/contextMetrics")
    def getGameContextMetrics(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/game/{gamePk}/winProbability")
    def getWinProbability(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/game/{game_pk}/boxscore")
    def boxscore(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/game/{game_pk}/content")
    def content(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/game/{game_pk}/feed/color")
    def colorFeed(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/game/{game_pk}/feed/color/timestamps")
    def colorTimestamps(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/game/{game_pk}/linescore")
    def linescore(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @api_path("/v1/game/{game_pk}/playByPlay")
    def playByPlay(self, **kwargs):
        return self.get_api_file_object(**kwargs)

