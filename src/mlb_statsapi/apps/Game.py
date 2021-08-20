"""
created by nikos at 8/4/21
"""
import json
import os
import datetime
import pytz

from time import sleep

import boto3
from mlb_statsapi.functions import YmdTHMSz_format, game_timestamp_format, strfdatetime, strpdatetime, strpdate
from mlb_statsapi.utils.aws import SNS
from mlb_statsapi.utils.stats_api_object import StatsAPIObject


EVENT_TOPIC_ARN: str = None
REGION: str = None

UTC = pytz.timezone("UTC")
apiName = os.path.basename(__file__).replace('.py', '')



def get_end_timecode(date: datetime.date, startTime: datetime.datetime):
    next_morning = datetime.datetime(
        date.year,
        date.month,
        date.day,
        8,
        tzinfo=pytz.timezone("utc")
    ) + datetime.timedelta(days=1)
    assert startTime < next_morning, f'get_end_time failed: {date=}, {startTime=}, {next_morning=}'
    return strfdatetime(next_morning, game_timestamp_format)


class TimecodeTopicClient:

    def __init__(self, sns: SNS, date: str, gamePk: int, startTime: str, sportId: int, *methods):
        self._timecodes = set()
        self._sns: SNS = sns
        self._date = date
        self._gamePk = gamePk
        self._startTime = startTime
        self._startTimecode = strfdatetime(strpdatetime(self._startTime, YmdTHMSz_format), game_timestamp_format)
        self._endTimecode = get_end_timecode(strpdate(self._date), strpdatetime(self._startTime, YmdTHMSz_format))
        self._sportId: int = sportId
        self._methods: tuple = tuple(sorted([*methods]))

    def add(self, *timecodes) -> list:
        for timecode in sorted(timecodes):
            if (self._startTimecode <= timecode <= self._endTimecode) and (timecode not in self._timecodes):
                self.publish(timecode, *self._methods)
                self._timecodes.add(timecode)

    def get_message(self, method: str, query_params: dict, force=False) -> dict:
        return json.dumps({
            "api": "Game",
            "method": method,
            "path_params": {
                "game_pk": self._gamePk
            },
            "query_params": query_params,
            "force": force
        })

    def _publish(self, timecode: str, method: str):
        if method == "liveGameDiffPatchV1":
            if not len(self._timecodes):
                return
            startTimecode = max(filter(timecode.__ge__, self._timecodes)),
            subject = f"Game-event-{method}-{startTimecode}-{timecode}"
            query_params = {
                "startTimecode": startTimecode,
                "endTimecode": timecode,
            }
        else:
            subject = f"Game-event-{method}-{timecode}"
            query_params = {"timecode": timecode}
        message = self.get_message(method, query_params=query_params)
        return self._sns.publish(
            TopicArn=EVENT_TOPIC_ARN,
            Subject=subject,
            Message=message,
            MessageAttributes={
              "Sport": {
                "DataType": "String",
                "StringValue": "MLB"
              }
            }
        )

    def publish(self, timecode: str, *methods):
        return [self._publish(timecode, method) for method in sorted(methods)]

    def is_active(self):
        return self._startTimecode <= datetime.datetime.now(tz=UTC).strftime(game_timestamp_format) <= self._endTimecode


def get_game(sch: StatsAPIObject, date: str, gamePk: int) -> list:
    return {g["gamePk"]: g for d in sch.obj["dates"] for g in d["games"] if d["date"] == date}[gamePk]


def refresh(sch: StatsAPIObject, date: str, gamePk: int) -> bool:
    if sch.obj is None:
        sch.get()
        return True
    Preview, Live, Final, Other = 'Preview', 'Live', 'Final', 'Other'
    sleepFor = 0
    abstractGameState = get_game(sch.get(), date, gamePk)["status"]["abstractGameState"]
    if abstractGameState == Final:
        return False
    elif abstractGameState == Preview:
        sleepFor = 15
        print(f"{apiName=} Schedule abstractGameState are in {Preview}, {sleepFor=}")
    elif abstractGameState == Live:
        sleepFor = 5
    else:
        raise ValueError(f"{abstractGameState=} not recognized from {[Preview, Live, Final, Other]}")
    print(f"{apiName=} {date=} {gamePk=} {abstractGameState=}, {sleepFor=}")
    sleep(sleepFor)
    return True


def cycle(ttc: TimecodeTopicClient, timestamps: StatsAPIObject):
    old = timestamps.dumps()
    new = timestamps.get().dumps()
    if old != new:
        ttc.add(*timestamps.obj)
        timestamps.gzip()
        timestamps.upload_file()


def run(**kwargs):
    """
    get the game timecodes and save new ones
    """
    from mlb_statsapi.model import StatsAPI
    global EVENT_TOPIC_ARN
    EVENT_TOPIC_ARN = os.environ["MLB_STATSAPI__EVENT_TOPIC_ARN"]
    global REGION
    REGION = os.environ["AWS_REGION"]
    date = kwargs["date"]
    gamePk = kwargs['gamePk']
    startTime = kwargs['startTime']
    sportId = kwargs['sportId']
    methods = kwargs["methods"]
    sch = StatsAPI.Schedule.schedule(query_params={"sportId": sportId, "date": date, "gamePk": gamePk})
    timestamps = StatsAPI.Game.liveTimestampv11(path_params={"game_pk": gamePk})
    ttc = TimecodeTopicClient(SNS(boto3.client("sns", region_name=REGION)), date, gamePk, startTime, sportId, *methods)
    while refresh(sch, date, gamePk) and ttc.is_active():
        cycle(ttc, timestamps)
    cycle(ttc, timestamps)
    return timestamps.obj