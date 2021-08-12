"""
created by nikos at 8/4/21
"""
import json
import os.path
import traceback

from time import sleep

from mlb_statsapi.utils.stats_api_object import StatsAPIObject


apiName = os.path.basename(__file__).replace('.py', '')


def get_games(sch: StatsAPIObject, date: str) -> list:
    return [g for d in sch.obj["dates"] for g in d["games"] if d["date"] == date]


def refresh(sch: StatsAPIObject, date: str) -> bool:
    if sch.obj is None:
        return True
    elif not len(sch.obj):
        return False
    abstractGameStates = {game["status"]["abstractGameState"] for game in get_games(sch, date)}
    Preview, Live, Final, Other = 'Preview', 'Live', 'Final', 'Other'
    sleepFor = 0
    if Live in abstractGameStates:
        sleepFor = 15
        print(f"{apiName=} abstractGameStates are {Live}, {sleepFor=}")
    elif Preview in abstractGameStates:
        sleepFor = 60
        print(f"{apiName=} abstractGameStates are in {Preview}, {sleepFor=}")
    elif Other in abstractGameStates:
        sleepFor = 30
        print(f"{apiName=} abstractGameStates are in {Other}, {sleepFor=}")
    elif {Final,} == abstractGameStates:
        print(f"{apiName=} abstractGameStates are all {Final}, {sleepFor=}")
        return False
    else:
        raise ValueError(f"{apiName} {abstractGameStates=} not recognized from {[Preview, Live, Final, Other]}")
    sleep(sleepFor)
    return True


def run(**kwargs):
    """
    get the schedule and save it if it changed,
    """
    from mlb_statsapi.model import StatsAPI
    sportId = kwargs["sportId"]
    date = kwargs["date"]
    sch = StatsAPI.Schedule.schedule(query_params={"sportId": sportId, "date": date})
    while refresh(sch, date):
        old = sch.dumps()
        new = sch.get().dumps()
        if old != new:
            sch.gzip()
            sch.upload_file()
    return {
        "date": date,
        "sportId": sportId,
        "size": os.path.getsize(sch.gz_path)
    }
