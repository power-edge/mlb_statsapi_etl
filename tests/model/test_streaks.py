"""
created by nikos at 4/29/21
"""
import unittest

from .base_test_mixin import ModelTestMixin, sleep_after_get


class TestStreaksModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.streaks import StreaksModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)

    @sleep_after_get()
    def test_get_getStreaks(self):
        self.dump(self.api_doc.getStreaks(query_params={
            'streakOrg': 'team'
        }).get().obj)

    @sleep_after_get()
    def test_get_highLowStats(self):
        self.dump(self.api_doc.highLowStats().get().obj)


from mlb_statsapi.model import StatsAPI

sch = StatsAPI.Schedule.schedule(
    query_params={
        "date": "2021-05-01",
        "sportId": 1
    }
)
sch.get()

game = StatsAPI.Game.liveGameV1(path_params={'game_pk': 12345})




schedule = StatsAPI.Schedule.schedule(
    query_params={"date": "2021-05-01", "
        game = StatsAPI.Game.liveGameV1(path_params={'game_pk': 12345})


if __name__ == '__main__':
    unittest.main()
