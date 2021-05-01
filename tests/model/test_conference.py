"""
created by nikos at 4/29/21
"""
import unittest

from .base_test_mixin import ModelTestMixin, sleep_after_get


class TestConferenceModel(unittest.TestCase, ModelTestMixin):
    from mlb_statsapi.model.api.conference import ConferenceModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)

    @sleep_after_get()
    def test_get_conferences(self):
        with self.assertRaises(AssertionError):
            self.api_doc.conferences()
        conferences = self.api_doc.conferences(path_params={"conferenceId": [5156, ]})
        self.dump(conferences.get().obj)


if __name__ == '__main__':
    unittest.main()
