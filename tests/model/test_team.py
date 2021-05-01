"""
created by nikos at 4/29/21
"""
import unittest

from .base_test_mixin import ModelTestMixin, sleep_after_get


class TestTeamModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.team import TeamModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)

    @sleep_after_get()
    def test_get_teams(self):
        self.dump(self.api_doc.teams(
            path_params={'teamId': 147}
        ).get().obj)

    @sleep_after_get()
    def test_get_affiliates(self):
        with self.assertRaises(NotImplementedError):
            self.dump(self.api_doc.affiliates(
                path_params={'teamId': 147},
                query_params={'sportId': 1}
            ).get().obj)

    @sleep_after_get()
    def test_get_allTeams(self):
        with self.assertRaises(NotImplementedError):
            self.api_doc.allTeams(
                path_params={
                    "teamId": 147
                }
            ).get()

    @sleep_after_get()
    def test_get_stats(self):
        """can't get anything out of this api"""
        self.dump(self.api_doc.stats(
            query_params={
                'sportId': 1,
                'leagueIds': '104',
                'season': '2020',
                "group": 'runs',
                'gameType': 'regularSeason',
            }
        ).get().obj)

    @sleep_after_get()
    def test_get_statsLeaders(self):
        """can't get anything out of this api"""
        self.dump(self.api_doc.statsLeaders(
            query_params={
                'sportId': 1,
                'leagueIds': '104',
                'season': '2020',
                "statGroup": 'hitting',
                "stats": "sabermetrics",
                'gameTypes': 'regularSeason',
            }
        ).get().obj)

    @sleep_after_get()
    def test_get_teamAffiliates(self):
        self.dump(self.api_doc.teamAffiliates(
            path_params={
                'teamId': 116
            }
        ).get().obj)

    @sleep_after_get()
    def test_get_alumni(self):
        self.dump(self.api_doc.alumni(
            path_params={
                'teamId': 116,
            },
            query_params={
                'season': 2020
            }
        ).get().obj)

    @sleep_after_get()
    def test_get_coaches(self):
        self.dump(self.api_doc.coaches(
            path_params={'teamId': 108}
        ).get().obj)

    @sleep_after_get()
    def test_get_history(self):
        """
        MLB StatsAPI will say the Angels played at Wrigley Field in 1961 season
        """
        hist = self.api_doc.history(
            path_params={
                'teamId': 108
            },
            query_params={
                # 'startSeason': 2012,
                'endSeason': 2013,
            }
        ).get()
        self.dump(hist.obj)
        angels_abbrevs = {'LAA', 'ANA', 'CAL'}
        assert all([team['abbreviation'] in angels_abbrevs for team in hist.obj['teams']])
        assert {t['season']: t for t in hist.obj['teams']}[1961]['venue']['name'] == 'Wrigley Field'  # lol

    @sleep_after_get()
    def test_get_leaders(self):
        self.dump(self.api_doc.leaders(
            path_params={
                'teamId': 120
            },
            query_params={
                'season': 2019,
                'leaderCategories': 'wins,earnedRunAverage',
                'limit': 1
            }
        ).get().obj)

    @sleep_after_get()
    def test_get_roster(self):
        self.dump(self.api_doc.roster(
            path_params={
                'teamId': 117,
                # 'rosterType': 'depthChart',
                'rosterType': 'active',
            },
            query_params={
                'date': '2018-05-22'
            }
        ).get().obj)


if __name__ == '__main__':
    unittest.main()
