"""
created by nikos at 8/10/21
"""
import json
import sys

from mlb_statsapi.utils import YmdTHMSz_format, game_timestamp_format, strpdatetime, strfdatetime


# noinspection PyPep8Naming
def get_timecode(game: dict, liveTimestampv11: callable):
    startPregame: str = strfdatetime(strpdatetime(game["startPregame"], YmdTHMSz_format), game_timestamp_format)
    timecodes = liveTimestampv11(path_params={"game_pk": game["gamePk"]}).get().obj
    if len(timecodes):
        return max([min(timecodes), *filter(startPregame.__ge__, timecodes)])
    return startPregame


# stats_api_object.
def getLiveGameV1(game: dict) -> dict:
    from mlb_statsapi.model import StatsAPI
    timecode = get_timecode(game, StatsAPI.Game.liveTimestampv11)
    return StatsAPI.Game.liveGameV1(
        path_params={
            "game_pk": game["gamePk"],
        },
        query_params={
            "timecode": timecode
        }
    ).get()


# noinspection PyPep8Naming
def set_official(liveGame) -> dict:
    from mlb_statsapi.utils import stats_api_object
    liveGame: stats_api_object.StatsAPIObject
    liveData = liveGame.obj["liveData"]
    officials = liveData["boxscore"]["officials"]
    return {
        "method": "person",
        "-pi": ' '.join(str(official["official"]["id"]) for official in officials),
        "officials": officials
    }


def set_team(game: dict) -> dict:
    return {
        "method": "roster",
        "rosterType": "depthChart"
    }


# noinspection PyPep8Naming,PyUnresolvedReferences
def get_forecast(game, liveGame: object) -> dict:
    return {
        "Venue": liveGame.obj["gameData"]["venue"],
        "Time": game["startPregame"],
        "Part": "gamePk=%s" % game["gamePk"]
    }


# noinspection PyPep8Naming
def lambda_handler(event: dict, context) -> dict:
    print(f"{context.function_name=}:{context.function_version=}, {context.log_group_name=}:{context.log_stream_name=}")
    print('event', json.dumps(event))
    sys.path.append("/opt")
    liveGame = getLiveGameV1(event["game"])
    return {
        "Team": set_team(event["game"]),
        "Official": set_official(liveGame),
        "Forecast": get_forecast(event["game"], liveGame)
    }
