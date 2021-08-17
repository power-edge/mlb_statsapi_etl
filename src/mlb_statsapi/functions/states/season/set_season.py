"""
created by nikos at 8/10/21
"""
import json
import sys


def set_season(seasonId, sportId=1) -> dict:
    from mlb_statsapi.model import StatsAPI
    season: StatsAPIObject = StatsAPI.Season.season(
        path_params={"seasonId": seasonId},
        query_params={"sportId": sportId}
    ).get()
    season.gzip()
    season.upload_file()
    return {s["seasonId"]: s for s in season.obj["seasons"]}[seasonId]


def lambda_handler(event: dict, context) -> bool:
    print(f"{context.function_name=}:{context.function_version=}, {context.log_group_name=}:{context.log_stream_name=}")
    print('event', json.dumps(event))
    sys.path.append("/opt")
    seasonId = event["seasonId"]
    sportId = event.get("sportId", "1")
    return set_season(seasonId, sportId)
