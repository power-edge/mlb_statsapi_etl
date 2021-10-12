"""
created by nikos at 8/4/21
"""
import datetime
import os
import tarfile
import typing
from concurrent.futures import ThreadPoolExecutor
from multiprocessing import cpu_count

import pytz

from time import sleep

from mlb_statsapi.model import StatsAPI
from mlb_statsapi.utils import YmdTHMSz_format, game_timestamp_format, strpdate, strpdatetime, strfdatetime
from mlb_statsapi.utils.aws import S3
from mlb_statsapi.utils.stats_api_object import StatsAPIObject
from mlb_statsapi.utils.log import LogMixin

UTC = pytz.timezone("UTC")
apiName = os.path.basename(__file__).replace('.py', '')

API = "Game"
Game = StatsAPI.Game


# noinspection PyPep8Naming
def get_end_timecode(date: datetime.date, startTime: datetime.datetime):
    """08:00 UTC ON THE NEXT DAY"""
    next_morning = datetime.datetime(
        date.year,
        date.month,
        date.day,
        8,
        tzinfo=pytz.timezone("utc")
    ) + datetime.timedelta(days=1)
    assert startTime < next_morning, f'get_end_time failed: {date=}, {startTime=}, {next_morning=}'
    return strfdatetime(next_morning, game_timestamp_format)


class Timecodes(LogMixin):

    __liveGameDiffPatchV1 = "liveGameDiffPatchV1"

    # noinspection PyPep8Naming,PyTypeChecker
    def __init__(self, date: str, gamePk: int, startTime: str, sportId: int, method: str):
        self._date = date
        self._gamePk = gamePk
        self._startTime = startTime
        self._startTimecode = strfdatetime(strpdatetime(self._startTime, YmdTHMSz_format), game_timestamp_format)
        self._endTimecode = get_end_timecode(strpdate(self._date), strpdatetime(self._startTime, YmdTHMSz_format))
        self._sportId: int = sportId
        self._method: str = method
        # the data for these will be manipulated manually during run()
        self._objects: typing.Dict[str, StatsAPIObject] = {}
        self._latest: StatsAPIObject = None
        self.latest_only = True
        self._size: typing.Dict[str, int] = {}

    @property
    def sizes(self):
        return [{"file": k, "size": v} for k, v in self._size.items()]

    def sink(self, executor: ThreadPoolExecutor, *timecodes: str):
        if any([self._sink_objects(executor, *batch) for batch in self.split(*timecodes)]):
            self.upload_latest()

    def _get_stats_api_object(self, **query_params) -> StatsAPIObject:
        return Game.methods[self._method](
            path_params=self.path_params,
            query_params=(query_params if len(query_params) else None)
        )

    def _fn(self, timecode: str, new: typing.Set[str]) -> StatsAPIObject:
        obj = self._get_stats_api_object(**self.get_statsapi_input(timecode)["query_params"])
        if obj.obj is not None:
            return obj
        if obj.exists('json'):
            obj.load('json')
        else:
            obj.get()
            if isinstance(obj.obj, list):
                obj.obj = {
                    self._method: obj.obj
                }
            obj.obj.update({
                "path_params": obj.path_params,
                "query_params": obj.query_params,
            })
            obj.save()
            new.add(timecode)
        return obj

    def _sink_objects(self, executor: ThreadPoolExecutor, *timecodes: str) -> bool:
        if not len(timecodes):
            self.log.warning("sink_objects has no timecodes to process.")
            return False
        missing = {*timecodes} - {timecode for timecode in self._objects.keys()}
        new = set()
        if len(missing):
            futures = {
                timecode: executor.submit(self._fn, timecode, new)
                for timecode in missing
            }
            while not all(fut.done() for fut in futures.values()):
                sleep(0.1)
            self._objects.update({
                timecode: fut.result() for timecode, fut in futures.items()
            })
            self.log.info("got %d new %s: %s" % (len(new), self._method, str(sorted(new))))
        else:
            self.log.info("no new %s" % self._method)
        return len(new) > 0

    def download_and_untar(self):
        helper = self._get_stats_api_object()
        if S3().exists(helper.bucket, helper.prefix("json.tar.gz")):
            if not os.path.isdir(os.path.dirname(helper.tar_gz_path)):
                os.makedirs(os.path.dirname(helper.tar_gz_path))
            helper.download_file("json.tar.gz")
            # un-tar and delete
            tf = tarfile.open(helper.tar_gz_path, mode="r:gz", format=tarfile.GNU_FORMAT)
            tf.extractall(path=os.path.dirname(helper.file_path))
            tf.close()
            self.log.info(f"uncompressed %s objects to %s" % (self._method, helper.tar_gz_path))

    def tar_and_upload(self):
        class Filter:
            count = 0
            log = self.log

            @classmethod
            def exclude(cls, attr):
                if attr.name.split(".")[-1] == 'json':
                    cls.count += 1
                    cls.log.debug("%s adding %s to tar.gz archive" % (cls.__name__, attr.name))
                    return attr

        if not len(self._objects):
            self.log.warning("skipping tar_and_upload with no objects")
            return
        helper = self._get_stats_api_object()
        if os.path.isfile(helper.tar_gz_path):
            os.remove(helper.tar_gz_path)
        if not os.path.exists(os.path.dirname(helper.tar_gz_path)):
            os.makedirs(os.path.dirname(helper.tar_gz_path))
        self.make_tarfile(helper.tar_gz_path, Filter, *self._objects.values())
        self.log.info(f"compressed %d objects to %s" % (Filter.count, helper.tar_gz_path))
        return helper.upload_file('json.tar.gz')

    # noinspection PyPep8Naming
    def make_tarfile(self, archive, Filter, *objects: StatsAPIObject):
        self.log.info(f"making tarfile {archive=} from {len(objects)} objects")
        with tarfile.open(archive, "w:gz", format=tarfile.GNU_FORMAT) as tar:
            for obj in objects:
                tar.add(obj.file_path, arcname=os.path.basename(obj.file_path), filter=Filter.exclude)
        self._size[archive] = os.path.getsize(archive)

    def upload_latest(self) -> None:
        if self._method == self.__liveGameDiffPatchV1 or (not len(self._objects)):
            self.log.warning("skipping upload_latest")
            return
        latest = self._objects[max(self._objects)]
        helper = self._get_stats_api_object(timecode="$LATEST")
        helper.obj = latest.obj
        helper.gzip()
        self._size[helper.gz_path] = os.path.getsize(helper.gz_path)
        helper.upload_file('json.gz')

    # noinspection PyPep8Naming
    def get_statsapi_input(self, timecode: str) -> dict:
        if self._method == self.__liveGameDiffPatchV1:
            extra = {}
            earlier = {*filter(timecode.__gt__, self._objects.keys())}
            if len(earlier):
                extra["startTimecode"] = max(earlier)
            query_params = {"endTimecode": timecode, **extra}
        else:
            query_params = {"timecode": timecode}
        return {
            "api": API,
            "method": self._method,
            "path_params": self.path_params,
            "query_params": query_params,
            "force": bool(os.environ.get(f"MLB_STATSAPI__FORCE__{API}_{self._method}", "False"))
        }

    @property
    def path_params(self): return {"game_pk": self._gamePk}

    # noinspection PyPep8Naming
    def is_active(self):
        return self._startTimecode <= datetime.datetime.now(tz=UTC).strftime(game_timestamp_format) <= self._endTimecode

    def split(self, *timecodes):
        if self._method == self.__liveGameDiffPatchV1:
            for timecode in sorted(timecodes):
                yield [timecode]
        else:
            for _ in range(1):
                yield sorted(timecodes)


# noinspection PyPep8Naming
def get_game(sch: StatsAPIObject, date: str, gamePk: int) -> dict:
    return {g["gamePk"]: g for d in sch.obj["dates"] for g in d["games"] if d["date"] == date}[gamePk]


# noinspection PyPep8Naming
def refresh(sch: StatsAPIObject, date: str, gamePk: int) -> bool:
    if sch.obj is None:
        sch.get()
        return True
    Preview, Live, Final, Other = 'Preview', 'Live', 'Final', 'Other'
    abstractGameState = get_game(sch.get(), date, gamePk)["status"]["abstractGameState"]
    if abstractGameState == Final:
        sch.log.info(f"{apiName=} Schedule abstractGameState is {abstractGameState}")
        return False
    elif abstractGameState == Preview:
        sleepFor = 15
        sch.log.info(f"{apiName=} Schedule abstractGameState are in {Preview}, {sleepFor=}")
    elif abstractGameState == Live:
        sleepFor = 5
    else:
        raise ValueError(f"{abstractGameState=} not recognized from {[Preview, Live, Final, Other]}")
    sch.log.info(f"{apiName=} {date=} {gamePk=} {abstractGameState=}, {sleepFor=}")
    sleep(sleepFor)
    return True


def cycle(executor: ThreadPoolExecutor, ts3c: Timecodes, timestamps: StatsAPIObject):
    old = timestamps.dumps()
    new = timestamps.get().dumps()
    if old != new:
        ts3c.sink(executor, *timestamps.obj)
    if not ts3c.latest_only:
        ts3c.sink(executor, *timestamps.obj)
        ts3c.tar_and_upload()
        ts3c.upload_latest()
        timestamps.gzip()
        timestamps.upload_file()


# noinspection PyPep8Naming,PyProtectedMember
def run(**kwargs):
    """
    get the game timecodes and save new ones
    """
    from mlb_statsapi.model import StatsAPI
    date = kwargs["date"]
    sportId = kwargs['sportId']
    gamePk = kwargs['gamePk']
    startTime = kwargs['startTime']
    method = kwargs["method"]
    sch: StatsAPIObject = StatsAPI.Schedule.schedule(query_params={"sportId": sportId, "date": date, "gamePk": gamePk})
    timestamps: StatsAPIObject = StatsAPI.Game.liveTimestampv11(path_params={"game_pk": gamePk})
    t0 = datetime.datetime.utcnow()
    tc = Timecodes(date, gamePk, startTime, sportId, method)
    tc.download_and_untar()
    max_workers = max([1, cpu_count() - 1])
    tc.log.info(f"ThreadPoolExecutor starting with {max_workers=}")
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        while refresh(sch, date, gamePk) and tc.is_active():
            cycle(executor, tc, timestamps)
        tc.latest_only = False
        cycle(executor, tc, timestamps)
    executor.shutdown()
    tc.log.info("ThreadPoolExecutor shutdown, time {}".format(t0.utcnow() - t0))
    return {
        "method": method,
        "date": date,
        "sportId": sportId,
        "gamePk": gamePk,
        "startTime": startTime,
        "size": [
            {
                "file": timestamps.gz_path,
                "size": os.path.getsize(timestamps.gz_path)
            },
            *tc.sizes
        ],
        "timecodes": timestamps.obj
    }
