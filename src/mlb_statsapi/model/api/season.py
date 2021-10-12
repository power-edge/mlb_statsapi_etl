"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpointModel
from mlb_statsapi.utils.stats_api_object import configure_api


class SeasonModel(MLBStatsAPIEndpointModel):

    @configure_api
    def allSeasons(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def season(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @configure_api
    def seasons(self, **kwargs):
        return self.get_api_file_object(**kwargs)

    @property
    def _methods(self) -> dict: return {m.__name__: m for m in (
        self.allSeasons,
        self.season,
        self.seasons
    )}
