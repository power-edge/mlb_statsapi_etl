"""
created by nikos at 4/29/21
"""
import unittest
from datetime import datetime, timedelta

from .base_test_mixin import ModelTestMixin


class TestPersonModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.person import PersonModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)

    def test_get_person(self):
        """
        beta-statsapi has shortcomings: personIds param is *NOT* allowMultiple!!!

        This is an allowable query of statsapi.mlb.com/api however the person.json model from beta-statspi has personId
         as a REQUIRED path param therefore the url path template resolution would fail

        f2 = self.api_doc.person(
            query_params={'personIds': '596295,543068'}  # + C.J. Cron
        )  # will work if changed personId param required = false
        """
        fo = self.api_doc.person(path_params={'personId': 596295})  # Austin Gomber lol
        self.dump(fo.get().obj)

    def test_get_changes(self):
        date_fmt = self.api_doc.date_formats['updatedSince']
        fo = self.api_doc.changes(query_params={
            'updatedSince': (datetime.utcnow() - timedelta(hours=1)).strftime(date_fmt)
        })
        self.dump(fo.get().obj)

    def test_get_freeAgents(self):
        fo = self.api_doc.freeAgents(query_params={
            'season': 2011,
            'order': 'desc'
        })
        self.dump(fo.get().obj)

    def test_get_award(self):
        fo = self.api_doc.award(
            path_params={'personId': 596295}
        )  # no kidding, Austin Gomber actually won some awards
        self.dump(fo.get().obj)

    def test_get_currentGameStats(self):
        fo = self.api_doc.currentGameStats(
            path_params={
                'personId': 453568,
            },  # Charlie Blackmon is playing right?
            query_params={
                'group': 'hitting'
            }
        )  #
        self.dump(fo.get().obj)

    def test_get_gameStats(self):
        # date_fmt = self.api_doc.date_formats['updatedSince']
        fo = self.api_doc.gameStats(
            path_params={
                'personId': 453568,
                'gamePk': 634309
            },
            query_params={
                'group': 'fielding'
            }
        )
        self.dump(fo.get().obj)


if __name__ == '__main__':
    unittest.main()
