"""
created by nikos at 4/26/21

Skip calling this file in any pytest with tests/model/test*
"""
import json
import os
import unittest


class ModelTestMixin:

    @staticmethod
    def dump(obj, indent=2):
        """does not have to dump to console, could dump to test file"""
        print(json.dumps(obj, indent=indent))

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


class GamePkMixin:
    # noinspection PyMethodMayBeStatic
    def _get_path_params(self): return {'game_pk': 634371}
