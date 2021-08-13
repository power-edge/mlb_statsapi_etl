"""
created by nikos at 8/5/21
"""
import datetime
import json
import sys

from .. import strpdate


def lambda_handler(event: dict, context) -> bool:
    print(f"{context.function_name=}:{context.function_version=}, {context.log_group_name=}:{context.log_stream_name=}")
    print('event', json.dumps(event))
    sys.path.append("/opt")
    from mlb_statsapi.model import StatsAPI
    date = strpdate(event["date"])
    seasonType = event.get("seasonType", "season")
    assert seasonType in {"season", "regularSeason", "preSeason", "postSeason",}
    season = {
        int(s["seasonId"]): s
        for s in StatsAPI.Season.season(
            path_params={"seasonId": date.year},
            query_params={"sportId": 1}
        ).get().obj["seasons"]
    }[date.year]
    start, end = strpdate(season[f"{seasonType}StartDate"]), strpdate(season[f"{seasonType}EndDate"])
    print(f"date_in_season: {start=} <= {date=} <= {end=}")
    return start <= date <= end
