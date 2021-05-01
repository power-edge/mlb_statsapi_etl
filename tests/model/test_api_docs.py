"""
created by nikos at 4/29/21

the api_doc will have a different schema therefore to not apply the ModelTestMixin
"""
import os
import unittest

from .base_test_mixin import sleep_after_get


class TestApiDocs(unittest.TestCase):

    @sleep_after_get()
    def test_ApiDocs(self):
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


if __name__ == '__main__':
    unittest.main()
