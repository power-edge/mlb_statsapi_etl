"""
created by nikos at 8/5/21
"""
import datetime
import json
import sys

from mlb_statsapi.utils import strpdate


def date_has_games(schedule: callable, date: str) -> bool:
    sch = schedule(
        query_params={
            "sportId": 1,
            "date": date
        }
    ).get()
    return bool(len(sch.obj["dates"]) and len({d["date"]: d for d in sch.obj["dates"]}[date]["games"]))


# noinspection PyPep8Naming
def date_in_season(season: callable, event: dict) -> bool:
    date = strpdate(event["date"])
    seasonType = event.get("seasonType", "season")
    assert seasonType in {"season", "regularSeason", "preSeason", "postSeason",}
    Season = season(
        path_params={"seasonId": date.year},
        query_params={"sportId": 1}
    ).get()
    sea = {
        int(s["seasonId"]): s
        for s in Season.obj["seasons"]
    }[date.year]
    Season.log.info(f"%d Season: %s" % (date.year, json.dumps(sea)))
    start, end = strpdate(sea[f"{seasonType}StartDate"]), strpdate(sea[f"{seasonType}EndDate"])
    Season.log.info(f"date_in_season: {start=} <= {date=} <= {end=}")
    return start <= date <= end


def lambda_handler(event: dict, context) -> bool:
    print(f"{context.function_name=}:{context.function_version=}, {context.log_group_name=}:{context.log_stream_name=}")
    print('event', json.dumps(event))
    sys.path.append("/opt")
    from mlb_statsapi.model import StatsAPI
    return date_in_season(StatsAPI.Season.season, event) and date_has_games(StatsAPI.Schedule.schedule, event["date"])
