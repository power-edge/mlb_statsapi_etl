"""
created by nikos at 4/29/21
"""
import unittest

from .base_test_mixin import ModelTestMixin


class TestAwardsModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.awards import AwardsModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)

    def test_get_awards(self):
        with self.assertRaises(AssertionError):
            self.api_doc.awards()
        mlb_hof = self.api_doc.awards(path_params={'awardId': r'MLBHOF'})
        self.dump(mlb_hof.get().obj)

    def test_get_awardRecipients(self):
        with self.assertRaises(AssertionError):
            self.api_doc.awardRecipients()
        award_recip_2010 = self.api_doc.awardRecipients(
            path_params={'awardId': r'MLBHOF'},
            query_params={'season': 2010}
        )
        self.dump(award_recip_2010.get().obj)


if __name__ == '__main__':
    unittest.main()
