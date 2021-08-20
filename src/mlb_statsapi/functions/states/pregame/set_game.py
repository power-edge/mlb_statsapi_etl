"""
created by nikos at 8/10/21
"""
import json
import sys

from mlb_statsapi.functions import game_timestamp_format, strfdatetime, strpdatetime, YmdTHMSz_format


def get_pregame_timecode(liveTimestampv11: callable, game: dict) -> str:
    from mlb_statsapi.utils.stats_api_object import StatsAPIObject
    start_pregame = strfdatetime(
        strpdatetime(game["startPregame"], YmdTHMSz_format),
        game_timestamp_format
    )
    game_pk = game["gamePk"]

    timecodes: StatsAPIObject = StatsAPI.Game.liveTimestampv11(
        path_params={"game_pk": game_pk},
    ).get()


def get_timecode(game: dict, liveTimestampv11: callable):
    startPregame: str = strfdatetime(strpdatetime(game["startPregame"], YmdTHMSz_format), game_timestamp_format)
    timecodes = liveTimestampv11(path_params={"game_pk": game["gamePk"]}).get().obj
    if len(timecodes):
      return max([min(timecodes), *filter(startPregame.__ge__, timecodes)])
    return startPregame


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


def get_sns_for_officials(liveGame) -> list:
    from mlb_statsapi.utils.stats_api_object import StatsAPIObject
    liveGame: StatsAPIObject
    gameData = liveGame.obj["gameData"]
    liveData = liveGame.obj["liveData"]
    return [{
        "api": "Person",
        "method": "person",
        "path_params": {
            "personId": official["official"]["id"]
        },
        "query_params": {
            "season": gameData["game"]["season"]
        }
    } for official in liveData["boxscore"]["officials"]]


def get_sns_for_teams(game: dict) -> list:
    return [{
        "api": "Team",
        "method": "roster",
        "path_params": {
            "teamId": team["team"]["id"],
            "rosterType": "depthChart"
        },
        "query_params": {
            "date": game["officialDate"]
        }
    } for half, team in game["teams"].items()]


def lambda_handler(event: dict, context) -> bool:
    print(f"{context.function_name=}:{context.function_version=}, {context.log_group_name=}:{context.log_stream_name=}")
    print('event', json.dumps(event))
    sys.path.append("/opt")
    liveGame = getLiveGameV1(event["game"])
    return {
        "teams": get_sns_for_teams(event["game"]),
        "officials": get_sns_for_officials(liveGame)
    }
