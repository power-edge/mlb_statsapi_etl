"""
created by nikos at 4/29/21
"""
import unittest

from .base_test_mixin import ModelTestMixin


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
        self.dump(fo.get().obj)


if __name__ == '__main__':
    unittest.main()
