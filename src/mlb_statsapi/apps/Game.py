"""
created by nikos at 8/4/21
"""
import json
import os.path

from time import sleep

from mlb_statsapi.utils.stats_api_object import StatsAPIObject


apiName = os.path.basename(__file__).replace('.py', '')


def get_game(sch: StatsAPIObject, date: str, gamePk: int) -> dict:
    return {game["gamePk"]: game for game in {
        d["date"]: d for d in sch.obj["dates"]
    }[date]["games"]}[gamePk]

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



def run(**kwargs):
    """
    get the schedule and save it if it changed,
    """
    from mlb_statsapi.model import StatsAPI
    date = kwargs["date"]
    gamePk = kwargs['gamePk']
    startTime = kwargs['startTime']
    sportId = kwargs['sportId']
    sch = StatsAPI.Schedule.schedule(query_params={"sportId": sportId, "date": date, "gamePk": gamePk})
    timestamps = StatsAPI.Game.liveTimestampv11(path_params={"game_pk": gamePk})
    while refresh(sch, date, gamePk):
        old = timestamps.dumps()
        new = timestamps.get().dumps()
        if old != new:
            timestamps.gzip()
            timestamps.upload_file()
    return timestamps.obj