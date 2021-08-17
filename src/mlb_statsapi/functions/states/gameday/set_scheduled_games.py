"""
created by nikos at 8/10/21
"""
import datetime
import json
import sys
import uuid

from .. import strf_game_date, strp_game_date, game_timestamp_format

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
        gameDate = strp_game_date(game["gameDate"])
        game["startPregame"] = (gameDate - datetime.timedelta(hours=1)).isoformat()
        game["startTimestamp"] = gameDate.strftime(game_timestamp_format)
        game["uid"] = str(uuid.uuid4()).split('-')[0]
        yield game



def lambda_handler(event: dict, context) -> bool:
    print(f"{context.function_name=}:{context.function_version=}, {context.log_group_name=}:{context.log_stream_name=}")
    print('event', json.dumps(event))
    sys.path.append("/opt")
    return [*get_games(event["date"])]
