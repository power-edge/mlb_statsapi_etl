"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpointModel
from mlb_statsapi.utils.stats_api_object import configure_api


class HomeRunDerbyModel(MLBStatsAPIEndpointModel):

    @configure_api
    def homeRunDerby(self, **kwargs):
        return self.ge(**kwargs)

    @configure_api
    def homeRunDerbyBracket(self, **kwargs):
        return self.ge(**kwargs)

    @configure_api
    def homeRunDerbyPool(self, **kwargs):
        return self.ge(**kwargs)

    @configure_api
    def homeRunDerbyGameBracket(self, **kwargs):
        return self.ge(**kwargs)

    @configure_api
    def homeRunDerbyGamePool(self, **kwargs):
        return self.ge(**kwargs)

    _methods = {m.__name__: m for m in (
        homeRunDerby,
        homeRunDerbyBracket,
        homeRunDerbyPool,
        homeRunDerbyGameBracket,
        homeRunDerbyGamePool
    )}
