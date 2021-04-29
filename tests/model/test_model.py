"""
created by nikos at 4/26/21
"""
import json
import os
import numpy as np
import unittest
from datetime import datetime, timedelta


def dump(obj, indent=2):
    """does not have to dump to console, could dump to test file"""
    print(json.dumps(obj, indent=indent))


class TestApiDocs(unittest.TestCase):

    def test_ApiDocs(self):

        """
        base serde.Model class which defines any beta-stats-api json document (api_docs, awards, game, etc)

        all MLBStatsAPIModel will have
         * a _fmt_rel_path to find the relative directory under ./configs/statsapi
         * fields: apiVersion, src_url, swaggerVersion
        """
        from mlb_statsapi.model.api_docs import ApiDocsModel as Mod
        open_path = Mod.get_open_path()
        assert os.path.isfile(open_path), f'{open_path} is not a file'
        doc_str = Mod.read_doc_str()
        doc_dct = Mod.read_doc(doc_str)
        api_doc = Mod.from_json(doc_str)
        # 1st level
        for attr in {*doc_dct.keys()} - {'authorizations', 'info'}:
            assert hasattr(api_doc, attr), f'unable to find {attr} in api_doc %s' % str(api_doc)
        # 2nd level
        for api in doc_dct['apis']:
            assert not {*api.keys()} - {'description', 'path', 'position'}


class ModelTestMixin:

    # noinspection PyAttributeOutsideInit
    @staticmethod
    def doSetUp(self) -> None:
        open_path = self.Mod.get_open_path()
        assert os.path.isfile(open_path), f'{open_path} is not a file'
        self.doc_str = self.Mod.read_doc_str()
        self.doc_dct = self.Mod.read_doc(self.doc_str)
        self.api_doc = self.Mod.from_json(self.doc_str)

    def test_Model(self):
        """
        base serde.Model class which defines any beta-stats-api json document (api_docs, awards, game, etc)

        all MLBStatsAPIModel will have
         * a _fmt_rel_path to find the relative directory under ./configs/statsapi
         * fields: apiVersion, src_url, swaggerVersion
        """
        # 1st level
        for attr in {*self.doc_dct.keys()} - {"models", }:
            assert hasattr(self.api_doc, attr), f'unable to find {attr} in api_doc %s' % str(self.api_doc)

        # 2nd level
        operations = []
        for api, api_mod in zip(self.doc_dct['apis'], self.api_doc.apis):
            diff = {*api.keys()} - {'description', 'path', 'operations'}
            assert not diff, 'found fields (%s) in api: %s' % (', '.join([*diff]), api['description'])
            operations.extend([*zip(api['operations'], api_mod.operations)])

        # 3rd level
        operation_keys = [
            'consumes',
            'deprecated',
            'items',
            'method',
            'nickname',
            'notes',
            'parameters',
            'produces',
            'responseMessages',
            'summary',
            'type',
            'uniqueItems'
        ]
        parameters = []
        for op, op_mod in operations:
            diff = op.keys() - {*operation_keys}
            assert not diff, 'found fields (%s) in operation: %s' % (', '.join([*diff]), op['nickname'])
            assert all([hasattr(op_mod, attr) for attr in operation_keys])
            parameters.extend([*zip(op['parameters'], op_mod.parameters)])

        # 4th level
        required_param_keys = [
            'allowMultiple',
            'defaultValue',
            'description',
            'name',
            'paramType',
            'type',
            'required',
        ]
        for param, param_mod in parameters:
            diff = param.keys() - {*required_param_keys, 'items', 'uniqueItems', 'format', 'enum'}
            assert not diff, 'found fields (%s) in parameter: %s' % (', '.join([*diff]), param['name'])
            assert all([hasattr(param_mod, attr) for attr in required_param_keys])


class TestAwardsModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.awards import AwardsModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)

    def test_get_awards(self):
        with self.assertRaises(AssertionError):
            self.api_doc.awards()
        mlb_hof = self.api_doc.awards(path_params={'awardId': r'MLBHOF'})
        dump(mlb_hof.get().obj)

    def test_get_awardRecipients(self):
        with self.assertRaises(AssertionError):
            self.api_doc.awardRecipients()
        award_recip_2010 = self.api_doc.awardRecipients(
            path_params={'awardId': r'MLBHOF'},
            query_params={'season': 2010}
        )
        dump(award_recip_2010.get().obj)


class TestBroadcastModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.broadcast import BroadcastModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)

    def test_get_getBroadcasts(self):  # TODO
        with self.assertRaises(AssertionError):
            self.api_doc.getBroadcasts()
        with self.assertRaises(AssertionError):
            self.api_doc.getBroadcasts(path_params={'broadcasterIds': [12345, ]})
        broadcasts = self.api_doc.getBroadcasts(query_params={'broadcasterIds': [12345, ]})
        dump(broadcasts.get().obj)


class TestConferenceModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.conference import ConferenceModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)

    def test_get_conferences(self):
        with self.assertRaises(AssertionError):
            self.api_doc.conferences()
        conferences = self.api_doc.conferences(path_params={"conferenceId": [5156, ]})
        dump(conferences.get().obj)


class TestConfigModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.config import ConfigModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)

    def test_get_baseballStats(self):
        fo = self.api_doc.baseballStats()
        dump(fo.get().obj)

    def test_get_eventTypes(self):
        fo = self.api_doc.eventTypes()
        dump(fo.get().obj)

    def test_get_fielderDetailTypes(self):
        fo = self.api_doc.fielderDetailTypes()
        dump(fo.get().obj)

    def test_get_gameStatus(self):
        fo = self.api_doc.gameStatus()
        dump(fo.get().obj)

    def test_get_gameTypes(self):
        fo = self.api_doc.gameTypes()
        dump(fo.get().obj)

    def test_get_gamedayTypes(self):
        fo = self.api_doc.gamedayTypes()
        dump(fo.get().obj)

    def test_get_groupByTypes(self):
        fo = self.api_doc.groupByTypes()
        dump(fo.get().obj)

    def test_get_hitTrajectories(self):
        fo = self.api_doc.hitTrajectories()
        dump(fo.get().obj)

    def test_get_jobTypes(self):
        fo = self.api_doc.jobTypes()
        dump(fo.get().obj)

    def test_get_languages(self):
        fo = self.api_doc.languages()
        dump(fo.get().obj)

    def test_get_leagueLeaderTypes(self):
        fo = self.api_doc.leagueLeaderTypes()
        dump(fo.get().obj)

    def test_get_logicalEvents(self):
        fo = self.api_doc.logicalEvents()
        dump(fo.get().obj)

    def test_get_metrics(self):
        fo = self.api_doc.metrics()
        dump(fo.get().obj)

    def test_get_pitchCodes(self):
        fo = self.api_doc.pitchCodes()
        dump(fo.get().obj)

    def test_get_pitchTypes(self):
        fo = self.api_doc.pitchTypes()
        dump(fo.get().obj)

    def test_get_platforms(self):
        fo = self.api_doc.platforms()
        dump(fo.get().obj)

    def test_get_playerStatusCodes(self):
        fo = self.api_doc.playerStatusCodes()
        dump(fo.get().obj)

    def test_get_positions(self):
        fo = self.api_doc.positions()
        dump(fo.get().obj)

    def test_get_reviewReasons(self):
        fo = self.api_doc.reviewReasons()
        dump(fo.get().obj)

    def test_get_rosterTypes(self):
        fo = self.api_doc.rosterTypes()
        dump(fo.get().obj)

    def test_get_runnerDetailTypes(self):
        fo = self.api_doc.runnerDetailTypes()
        dump(fo.get().obj)

    def test_get_scheduleEventTypes(self):
        fo = self.api_doc.scheduleEventTypes()
        dump(fo.get().obj)

    def test_get_sitCodes(self):
        fo = self.api_doc.sitCodes()
        dump(fo.get().obj)

    def test_get_sky(self):
        fo = self.api_doc.sky()
        dump(fo.get().obj)

    def test_get_aggregateSortEnum(self):
        fo = self.api_doc.aggregateSortEnum()
        dump(fo.get().obj)

    def test_get_standingsTypes(self):
        fo = self.api_doc.standingsTypes()
        dump(fo.get().obj)

    def test_get_statFields(self):
        fo = self.api_doc.statFields()
        dump(fo.get().obj)

    def test_get_statGroups(self):
        fo = self.api_doc.statGroups()
        dump(fo.get().obj)

    def test_get_statTypes(self):
        fo = self.api_doc.statTypes()
        dump(fo.get().obj)

    def test_get_statSearchConfig(self):
        fo = self.api_doc.statSearchConfig()
        dump(fo.get().obj)

    def test_get_statSearchGroupByTypes(self):
        fo = self.api_doc.statSearchGroupByTypes()
        dump(fo.get().obj)

    def test_get_statSearchParams(self):
        fo = self.api_doc.statSearchParams()
        dump(fo.get().obj)

    def test_get_statSearchStats(self):
        fo = self.api_doc.statSearchStats()
        dump(fo.get().obj)

    def test_get_transactionTypes(self):
        fo = self.api_doc.transactionTypes()
        dump(fo.get().obj)

    def test_get_windDirection(self):
        fo = self.api_doc.windDirection()
        dump(fo.get().obj)

    def test_get_awards(self):
        fo = self.api_doc.awards()
        dump(fo.get().obj)


class TestDivisionModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.division import DivisionModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)

    def test_get_divisions(self):
        with self.assertRaises(AssertionError):
            self.api_doc.divisions()
        fo = self.api_doc.divisions(
            path_params={'divisionId': 205},
            query_params={'sportId': 1}
        )  # NL Central
        dump(fo.get().obj)


class TestDraftModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.draft import DraftModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)

    def test_get_draftPicks(self):
        with self.assertRaises(AssertionError):
            self.api_doc.draftPicks()
        # this returns a huge payload, skipping
        # fo = self.api_doc.draftPicks(path_params={'year': 2015}, query_params={'limit': 1})
        # dump(fo.get().obj)

    def test_get_draftProspects(self):
        with self.assertRaises(AssertionError):
            self.api_doc.draftPicks()
        fo = self.api_doc.draftProspects(path_params={'year': 2018}, query_params={'limit': 1})
        dump(fo.get().obj)

    def test_get_latestDraftPicks(self):
        with self.assertRaises(AssertionError):
            self.api_doc.latestDraftPicks()
        fo = self.api_doc.latestDraftPicks(path_params={'year': 2018})
        dump(fo.get().obj)


class GamePkMixin:
    # noinspection PyMethodMayBeStatic
    def _get_path_params(self): return {'game_pk': 634371}


class TestGameModel(unittest.TestCase, ModelTestMixin, GamePkMixin):
    from mlb_statsapi.model.api.game import GameModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)

    def test_get_liveGameV1(self):
        with self.assertRaises(AssertionError):
            self.api_doc.liveGameV1()
        fo = self.api_doc.liveGameV1(path_params=self._get_path_params())
        dump(fo.get().obj)
        fo_tc = self.api_doc.liveGameV1(path_params=self._get_path_params(),
                                        query_params={'timecode': '20210428_180924'})
        dump(fo.get().obj)
        assert fo.file_path != fo_tc.file_path
        assert len(json.dumps(fo.obj)) > len(json.dumps(fo_tc.obj))

    def test_get_liveGameDiffPatchV1(self):
        with self.assertRaises(AssertionError):
            self.api_doc.liveGameDiffPatchV1()
        fo = self.api_doc.liveGameDiffPatchV1(
            path_params=self._get_path_params(),
            query_params={
                "startTimecode": "20210428_180924",
                "endTimecode": "20210428_180931"
            }
        )
        dump(fo.get().obj)

    def test_get_liveTimestampv11(self):
        with self.assertRaises(AssertionError):
            self.api_doc.liveTimestampv11()
        fo = self.api_doc.liveTimestampv11(path_params=self._get_path_params())
        dump(fo.get().obj)

    def test_get_currentGameStats(self):
        with self.assertRaises(AssertionError):
            self.api_doc.currentGameStats()
        date_fmt = self.api_doc.date_formats['updatedSince']
        fo = self.api_doc.currentGameStats(
            query_params={
                'updatedSince': (datetime.utcnow() - timedelta(hours=1)).strftime(date_fmt)
            }
        )
        dump(fo.get().obj)

    def test_get_getGameContextMetrics(self):
        with self.assertRaises(AssertionError):
            self.api_doc.getGameContextMetrics()
        # NOTE: THE PATH PARAM IS NAMED UNLIKE MOST GAME_PK
        fo = self.api_doc.getGameContextMetrics(path_params={'gamePk': self._get_path_params()['game_pk']})
        dump(fo.get().obj)

    def test_get_getWinProbability(self):
        with self.assertRaises(AssertionError):
            self.api_doc.getWinProbability()
        fo = self.api_doc.getWinProbability(path_params={'gamePk': self._get_path_params()['game_pk']})
        dump(fo.get().obj)

    def test_get_boxscore(self):
        with self.assertRaises(AssertionError):
            self.api_doc.boxscore()
        fo = self.api_doc.boxscore(
            path_params=self._get_path_params()
        )
        dump(fo.get().obj)
        fo_ts = self.api_doc.boxscore(
            path_params=self._get_path_params(),
            query_params={'timecode': '20210428_180924'}
        )
        dump(fo_ts.get().obj)
        assert len(json.dumps(fo.obj)) > len(json.dumps(fo_ts.obj))

    def test_get_content(self):
        with self.assertRaises(AssertionError):
            self.api_doc.content()
        fo = self.api_doc.content(
            path_params=self._get_path_params(),
            query_params={'highlightLimit': 1}
        )
        dump(fo.get().obj)

    def test_get_colorFeed(self):
        fo = self.api_doc.colorFeed(
            path_params=self._get_path_params(),
            query_params={'timecode': '20210428_180924'}
        )
        dump(fo.get().obj)

    def test_get_colorTimestamps(self):
        fo = self.api_doc.colorTimestamps(path_params=self._get_path_params())
        dump(fo.get().obj)

    def test_get_linescore(self):
        fo = self.api_doc.linescore(path_params=self._get_path_params())
        dump(fo.get().obj)
        fo_ts = self.api_doc.linescore(
            path_params=self._get_path_params(),
            query_params={'timecode': '20210428_180000'}  # different, earlier timestamp than ^
        )
        dump(fo_ts.get().obj)
        assert len(json.dumps(fo.obj)) > len(json.dumps(fo_ts.obj))

    def test_get_playByPlay(self):
        fo = self.api_doc.playByPlay(
            path_params=self._get_path_params(),
            query_params={'timecode': '20210428_180000'}
        )
        dump(fo.get().obj)


class TestGamepaceModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.gamepace import GamepaceModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)


class TestHighLowModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.highlow import HighLowModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)
    #
    # def test_highLowStats(self):
    #     print(self.api_doc.highLowStats())

    # def test_highLow(self):
    #     print(self.api_doc.highLow(path_params={'highLowType': ['TEAM']}, query_params={'sportId': 1}))


class TestHomeRunDerbyModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.homerunderby import HomeRunDerbyModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)


class TestJobModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.job import JobModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)


class TestLeagueModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.league import LeagueModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)


class TestMilestonesModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.milestones import MilestonesModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)


class TestPersonModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.person import PersonModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)


class TestScheduleModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.schedule import ScheduleModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)


class TestSeasonModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.season import SeasonModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)


class TestSportsModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.sports import SportsModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)


class TestStandingsModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.standings import StandingsModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)


class TestStatsModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.stats import StatsModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)


class TestStreaksModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.streaks import StreaksModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)


class TestTeamModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.team import TeamModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)


