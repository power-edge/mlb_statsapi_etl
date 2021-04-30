"""
created by nikos at 4/29/21
"""
import unittest
from time import sleep

from .base_test_mixin import ModelTestMixin


class TestScheduleModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.schedule import ScheduleModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)

    def test_get_schedule(self):
        # this should work
        self.dump(self.api_doc.schedule(query_params={'sportId': 1}).get().obj)
        sleep(1)
        # so should this
        sch = self.api_doc.schedule(
            query_params={
                'sportId': 1,
                'date': '2019-07-28'
            }
        ).get()
        assert len(sch.obj['dates']) == 1
        sch_day = sch.obj['dates'][0]
        assert sch_day["date"] == sch.query_params['date']
        sleep(1)
        # and this
        sch = self.api_doc.schedule(
            query_params={
                'sportId': 1,
                'date': '2019-07-28',
                'gamePk': 565079
            }
        ).get()
        assert len(sch.obj['dates'][0]["games"]) == 1
        sleep(1)
        # and these three days of nyy schedule
        sch = self.api_doc.schedule(
            query_params={
                'sportId': 1,
                'startDate': '2019-07-28',
                'endDate': '2019-07-30',
                'teamId': 147
            }
        ).get()
        assert len(sch.obj['dates']) == 2, 'nyy has no games on https://www.mlb.com/schedule/2019-07-29'
        assert all([
            sch.query_params['teamId'] in {tm['team']['id'] for tm in game['teams'].values()}
            for game in [gm for dt in sch.obj['dates'] for gm in dt['games']]
        ])

    def test_get_tieGames(self):
        self.dump(self.api_doc.tieGames(query_params={
            'sportId': 1,
            'season': 2021,
            # 'gameTypes': 'r'  is not working
        }).get().obj)

    def test_get_postseasonScheduleSeries(self):
        self.dump(self.api_doc.postseasonScheduleSeries(query_params={
            'sportId': 1,
            'season': 2020,
            'teamId': 139,
        }).get().obj)

    def test_get_tuneIn(self):
        self.dump(self.api_doc.tuneIn(query_params={
            'sportId': 1,
            'season': 2020,
            'teamId': 139,
        }).get().obj)

    def test_get_scheduleType(self):
        # todo - the docs on this are no good therefore it will raise a key error, see the method in ScheduleModel
        with self.assertRaises(KeyError):
            sch.dump(self.api_doc.scheduleType(
                query_params={
                    'sportId': 1,
                    'gameType': 'R'
                }
            ).get().obj)


if __name__ == '__main__':
    unittest.main()
