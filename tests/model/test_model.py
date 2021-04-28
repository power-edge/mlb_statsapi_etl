"""
created by nikos at 4/26/21
"""
import json
import os
import numpy as np
import unittest


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

    def test_get(self):
        pass


class TestBroadcastModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.broadcast import BroadcastModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)


class TestConferenceModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.conference import ConferenceModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)


class TestConfigModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.config import ConfigModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)


class TestDivisionModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.division import DivisionModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)


class TestDraftModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.draft import DraftModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)


class TestGameModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.game import GameModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)


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


