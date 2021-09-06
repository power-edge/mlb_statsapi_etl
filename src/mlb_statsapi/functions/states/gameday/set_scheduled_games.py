"""
created by nikos at 8/10/21
"""
import datetime
import json
import os
import sys
import uuid

from mlb_statsapi.utils import game_timestamp_format, strpdatetime

PREGAME_SFN_ARN = os.environ["MLB_STATSAPI__PREGAME_SFN_ARN"]


# noinspection PyPep8Naming
def get_games(date: str) -> dict:
    from mlb_statsapi.model import StatsAPI
    for game in {
        d["date"]: d
        for d in StatsAPI.Schedule.schedule(
            query_params={
                "sportId": 1,
                "date": date
            }
        ).get().obj["dates"]
    }[date]["games"]:
        gameDate = strpdatetime(game["gameDate"])
        game["startPregame"] = (gameDate - datetime.timedelta(hours=1)).isoformat()
        game["startTimestamp"] = gameDate.strftime(game_timestamp_format)
        game["uid"] = str(uuid.uuid4()).split('-')[0]
        game["workflow"] = {
            "name": PREGAME_SFN_ARN.split(":")[-1],
            "arn": PREGAME_SFN_ARN
        }
        yield game


def lambda_handler(event: dict, context) -> dict:
    print(f"{context.function_name=}:{context.function_version=}, {context.log_group_name=}:{context.log_stream_name=}")
    print('event', json.dumps(event))
    sys.path.append("/opt")
    games = [*get_games(event["date"])]
    return {
        "firstPregame": min([g["startPregame"] for g in games]),
        "games": games
    }
