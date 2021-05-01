"""
created by nikos at 4/29/21
"""
import json
import unittest
from datetime import datetime, timedelta

from .base_test_mixin import GamePkMixin, ModelTestMixin, sleep_after_get


class TestGameModel(unittest.TestCase, ModelTestMixin, GamePkMixin):
    from mlb_statsapi.model.api.game import GameModel as Mod

    def setUp(self) -> None:
        # noinspection PyTypeChecker
        self.doSetUp(self)

    @sleep_after_get()
    def test_get_liveGameV1(self):
        with self.assertRaises(AssertionError):
            self.api_doc.liveGameV1()
        fo = self.api_doc.liveGameV1(path_params=self._get_path_params())
        self.dump(fo.get().obj)
        fo_tc = self.api_doc.liveGameV1(path_params=self._get_path_params(),
                                        query_params={'timecode': '20210428_180924'})
        self.dump(fo.get().obj)
        assert fo.file_path != fo_tc.file_path
        assert len(json.dumps(fo.obj)) > len(json.dumps(fo_tc.obj))

    @sleep_after_get()
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
        self.dump(fo.get().obj)

    @sleep_after_get()
    def test_get_liveTimestampv11(self):
        with self.assertRaises(AssertionError):
            self.api_doc.liveTimestampv11()
        fo = self.api_doc.liveTimestampv11(path_params=self._get_path_params())
        self.dump(fo.get().obj)

    @sleep_after_get()
    def test_get_currentGameStats(self):
        with self.assertRaises(AssertionError):
            self.api_doc.currentGameStats()
        date_fmt = self.api_doc.date_formats['updatedSince']
        fo = self.api_doc.currentGameStats(
            query_params={
                'updatedSince': (datetime.utcnow() - timedelta(hours=1)).strftime(date_fmt)
            }
        )
        self.dump(fo.get().obj)

    @sleep_after_get()
    def test_get_getGameContextMetrics(self):
        with self.assertRaises(AssertionError):
            self.api_doc.getGameContextMetrics()
        # NOTE: THE PATH PARAM IS NAMED UNLIKE MOST GAME_PK
        fo = self.api_doc.getGameContextMetrics(path_params={'gamePk': self._get_path_params()['game_pk']})
        self.dump(fo.get().obj)

    @sleep_after_get()
    def test_get_getWinProbability(self):
        with self.assertRaises(AssertionError):
            self.api_doc.getWinProbability()
        fo = self.api_doc.getWinProbability(path_params={'gamePk': self._get_path_params()['game_pk']})
        self.dump(fo.get().obj)

    @sleep_after_get()
    def test_get_boxscore(self):
        with self.assertRaises(AssertionError):
            self.api_doc.boxscore()
        fo = self.api_doc.boxscore(
            path_params=self._get_path_params()
        )
        self.dump(fo.get().obj)
        fo_ts = self.api_doc.boxscore(
            path_params=self._get_path_params(),
            query_params={'timecode': '20210428_180924'}
        )
        self.dump(fo_ts.get().obj)
        assert len(json.dumps(fo.obj)) > len(json.dumps(fo_ts.obj))

    @sleep_after_get()
    def test_get_content(self):
        with self.assertRaises(AssertionError):
            self.api_doc.content()
        fo = self.api_doc.content(
            path_params=self._get_path_params(),
            query_params={'highlightLimit': 1}
        )
        self.dump(fo.get().obj)

    @sleep_after_get()
    def test_get_colorFeed(self):
        fo = self.api_doc.colorFeed(
            path_params=self._get_path_params(),
            query_params={'timecode': '20210428_180924'}
        )
        self.dump(fo.get().obj)

    @sleep_after_get()
    def test_get_colorTimestamps(self):
        fo = self.api_doc.colorTimestamps(path_params=self._get_path_params())
        self.dump(fo.get().obj)

    @sleep_after_get()
    def test_get_linescore(self):
        fo = self.api_doc.linescore(path_params=self._get_path_params())
        self.dump(fo.get().obj)
        fo_ts = self.api_doc.linescore(
            path_params=self._get_path_params(),
            query_params={'timecode': '20210428_180000'}  # different, earlier timestamp than ^
        )
        self.dump(fo_ts.get().obj)
        assert len(json.dumps(fo.obj)) > len(json.dumps(fo_ts.obj))

    @sleep_after_get()
    def test_get_playByPlay(self):
        fo = self.api_doc.playByPlay(
            path_params=self._get_path_params(),
            query_params={'timecode': '20210428_180000'}
        )
        self.dump(fo.get().obj)


if __name__ == '__main__':
    unittest.main()
