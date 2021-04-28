"""
created by nikos at 4/26/21
"""
from ..base import MLBStatsAPIEndpoint
from ..utils import api_path


class HomeRunDerbyModel(MLBStatsAPIEndpoint):

    @api_path("/v1/homeRunDerby", name="homeRunDerbyBracket")
    def homeRunDerby(self, **kwargs):
        return self.ge(**kwargs)

    @api_path("/v1/homeRunDerby/bracket")
    def homeRunDerbyBracket(self, **kwargs):
        return self.ge(**kwargs)

    @api_path("/v1/homeRunDerby/pool")
    def homeRunDerbyPool(self, **kwargs):
        return self.ge(**kwargs)

    @api_path("/v1/homeRunDerby/{gamePk}/bracket", name="homeRunDerbyBracket")
    def homeRunDerbyGameBracket(self, **kwargs):
        return self.ge(**kwargs)

    @api_path("/v1/homeRunDerby/{gamePk}/pool", name="homeRunDerbyPool")
    def homeRunDerbyGamePool(self, **kwargs):
        return self.ge(**kwargs)
