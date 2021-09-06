"""
created by nikos at 8/4/21
"""
import json
import os.path
import traceback

from time import sleep

import utils.stats_api_object
from mlb_statsapi.utils.stats_api_object import StatsAPIObject


apiName = os.path.basename(__file__).replace('.py', '')


def get_games(sch: StatsAPIObject, date: str) -> list:
    return [g for d in sch.obj["dates"] for g in d["games"] if d["date"] == date]


# noinspection PyPep8Naming
def refresh(sch: StatsAPIObject, date: str) -> bool:
    if sch.obj is None:
        return True
    elif not len(sch.obj):
        return False
    abstractGameStates = {game["status"]["abstractGameState"] for game in get_games(sch, date)}
    Preview, Live, Final, Other = 'Preview', 'Live', 'Final', 'Other'
    sleepFor = 0
    if Live in abstractGameStates:
        sleepFor = 60 * 1
        sch.log.info(f"{apiName=} abstractGameStates are {Live}, {sleepFor=}")
    elif Preview in abstractGameStates:
        sleepFor = 60 * 15
        sch.log.info(f"{apiName=} abstractGameStates are in {Preview}, {sleepFor=}")
    elif Other in abstractGameStates:
        sleepFor = 60 * 5
        sch.log.info(f"{apiName=} abstractGameStates are in {Other}, {sleepFor=}")
    elif {Final,} == abstractGameStates:
        sch.log.info(f"{apiName=} abstractGameStates are all {Final}, {sleepFor=}")
        return False
    else:
        raise ValueError(f"{apiName} {abstractGameStates=} not recognized from {[Preview, Live, Final, Other]}")
    sleep(sleepFor)
    return True


def cycle(sch):
    old = sch.dumps()
    new = sch.get().dumps()
    if old != new:
        sch.gzip()
        sch.upload_file()


# noinspection PyPep8Naming
def run(**kwargs):
    """
    get the schedule and save it if it changed,
    """
    from mlb_statsapi.model import StatsAPI
    sportId = kwargs["sportId"]
    date = kwargs["date"]
    method = kwargs["method"]
    sch: StatsAPIObject = StatsAPI.Schedule.schedule(query_params={"sportId": sportId, "date": date})
    while refresh(sch, date):
        cycle(sch)
    cycle(sch)
    return {
        "method": method,
        "date": date,
        "sportId": sportId,
        "games": [
            {
                "gamePk": game["gamePk"],
                "link": game["link"],
                "gameType": game["gameType"],
                "season": game["season"],
                "gameDate": game["gameDate"],
                "officialDate": game["officialDate"],
                "status": {
                    "abstractGameState": game["status"]["abstractGameState"],
                    "statusCode": game["status"]["statusCode"]
                },
                "venue": game["venue"],
                "teams": {half: team["team"] for half, team in game["teams"].items()}
            } for game in get_games(sch, date)
        ],
        "file": sch.gz_path,
        "size": os.path.getsize(sch.gz_path)
    }
