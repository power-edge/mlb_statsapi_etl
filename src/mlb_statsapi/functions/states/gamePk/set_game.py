"""
created by nikos at 8/11/21
"""

import json
import sys

from functions import strfdatetime, strpdatetime, game_date_format, game_timestamp_format
from mlb_statsapi.utils.stats_api_object import StatsAPIObject


false, true = False, True
EVENT = {
  "date": "2021-08-12",
  "AWS_STEP_FUNCTIONS_TASK_TOKEN": "AAAAKgAAAAIAAAAAAAAAAQ8ADvv/m2wBOawLJK7bQ+nCKXMR/zI76XRv1iFS4++Ir/cEW36XjGSoQHwuZGbbSvjkFCprFbxROmd6w/638C+M6FzKspMIoLm2WIljt7B77BWnQfoLTnb9ylFwNB3yHHf8BKLbFB7iU2Dv63hj5Nx3jV89p0rzjhECBfwad86fOs8g/v67WAW+y/R0fQK0jyzO2VSwzwyAx4e0wLLkrsRaUQ2ZowCDQpeki1JMsWh9EVI4kAPtehxFzRQciWLAooWJPois1ouzO9aFa8PzI1kci5tXyPLUX9BIOi6eirHCIBMx2dxIkyK/2U5HGhkOttgsqoomtKuUmBTlbk09FD4SGSNkXVGMSRU/GtU82nIxMVkRIGt1TlGdbRVRi7eCmJhowvM6aMR/ZlDab3vammVLcNs/etW7a0AzRFWgPCf0NfDZeMSE45z/I6zssQ6+V2Tu/MEJszY2nV0EwF+qZ4U17x++nvszQtIWhPMrnW5R9zf2eJ3rELDLLUyeTbl4cwb7+gP71QgK2Gfm1rr5mjIAAB2kQn6fSzyK/Pd7TO4UG323DecjHaFjQcfNqdb/9OjzfFBxqFkt18rrrLuGKWZ0/ypCxJ7q5mHDSUzMaRRpLMpwhqvTIr9w+wS5ycqC1g==",
  "game": {
    "gamePk": 632938,
    "link": "/api/v1.1/game/632938/feed/live",
    "gameType": "R",
    "season": "2021",
    "gameDate": "2021-08-12T20:05:00Z",
    "officialDate": "2021-08-12",
    "status": {
      "abstractGameState": "Live",
      "codedGameState": "I",
      "detailedState": "In Progress",
      "statusCode": "I",
      "startTimeTBD": false,
      "abstractGameCode": "L"
    },
    "teams": {
      "away": {
        "leagueRecord": {
          "wins": 56,
          "losses": 60,
          "pct": ".483"
        },
        "score": 6,
        "team": {
          "id": 116,
          "name": "Detroit Tigers",
          "link": "/api/v1/teams/116"
        },
        "splitSquad": false,
        "seriesNumber": 36
      },
      "home": {
        "leagueRecord": {
          "wins": 38,
          "losses": 74,
          "pct": ".339"
        },
        "score": 4,
        "team": {
          "id": 110,
          "name": "Baltimore Orioles",
          "link": "/api/v1/teams/110"
        },
        "splitSquad": false,
        "seriesNumber": 37
      }
    },
    "venue": {
      "id": 2,
      "name": "Oriole Park at Camden Yards",
      "link": "/api/v1/venues/2"
    },
    "content": {
      "link": "/api/v1/game/632938/content"
    },
    "gameNumber": 1,
    "publicFacing": true,
    "doubleHeader": "N",
    "gamedayType": "P",
    "tiebreaker": "N",
    "calendarEventID": "14-632938-2021-08-12",
    "seasonDisplay": "2021",
    "dayNight": "day",
    "scheduledInnings": 9,
    "reverseHomeAwayStatus": false,
    "inningBreakLength": 120,
    "gamesInSeries": 3,
    "seriesGameNumber": 3,
    "seriesDescription": "Regular Season",
    "recordSource": "S",
    "ifNecessary": "N",
    "ifNecessaryDescription": "Normal Game",
    "waitUntil": "2021-08-12T19:05:00+00:00",
    "startTimestamp": "20210812_200500",
    "uid": "518141d1"
  },
  "AWS_STEP_FUNCTIONS_STARTED_BY_EXECUTION_ID": "arn:aws:states:us-west-2:623650261134:execution:mlb_statsapi_etl_gameday:gameday-20210812-d911193f-8724-69d0-1355-53f8d5ba52d4"
}


def get_timecode(game: dict, liveTimestampv11: callable):
    waitUntil: str = strfdatetime(strpdatetime(game["waitUntil"], game_date_format), game_timestamp_format)
    timecodes = liveTimestampv11(path_params={"game_pk": game["gamePk"]}).get().obj
    if len(timecodes):
      return max([min(timecodes), *filter(waitUntil.__ge__, timecodes)])
    return waitUntil



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


def set_game(liveGame: StatsAPIObject):
  pass




def lambda_handler(event: dict, context) -> bool:
    print(f"{context.function_name=}:{context.function_version=}, {context.log_group_name=}:{context.log_stream_name=}")
    print('event', json.dumps(event))
    sys.path.append("/opt")
    liveGame = getLiveGameV1(event["game"])
    return set_game(liveGame)


if __name__ == "__main__":
    from mlb_statsapi.model import StatsAPI
    # print(json.dumps(EVENT["game"], indent=4))
    timestamp = get_timecode(EVENT["game"], StatsAPI.Game.liveTimestampv11)
    print(f"{timestamp=}")