"""
created by nikos at 8/10/21
"""
import json
import sys

from mlb_statsapi.model import StatsAPI
from mlb_statsapi.utils import stats_api_object


# noinspection PyPep8Naming
def set_season(seasonId, sportId=1) -> dict:
    season: stats_api_object.StatsAPIObject = StatsAPI.Season.season(
        path_params={"seasonId": seasonId},
        query_params={"sportId": sportId}
    ).get()
    season.gzip()
    stats_api_object.upload_file()
    return {s["seasonId"]: s for s in season.obj["seasons"]}[seasonId]


# noinspection PyPep8Naming
def lambda_handler(event: dict, context):
    print(f"{context.function_name=}:{context.function_version=}, {context.log_group_name=}:{context.log_stream_name=}")
    print('event', json.dumps(event))
    sys.path.append("/opt")
    seasonId = event["seasonId"]
    sportId = event.get("sportId", "1")
    return set_season(seasonId, sportId)
