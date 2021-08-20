"""
created by nikos at 8/11/21
"""
import json
import sys


def depthChart(roster: callable, team: dict, date: str) -> dict:
    return roster(
        path_params={
            "teamId": team["team"]["id"],
            "rosterType": "depthChart"
        },
        query_params={
            "date": date
        },
    ).get().obj


def get_player_sns_input_for_team(roster: callable, team: dict, date: str):
    return [{
        "api": "Person",
        "method": "person",
        "path_params": {
            "personId": person["person"]["id"]
        },
        "query_params": {
            "season": date[:4]
        }
    } for person in depthChart(roster, team, date)["roster"]]


def lambda_handler(event: dict, context) -> bool:
    print(f"{context.function_name=}:{context.function_version=}, {context.log_group_name=}:{context.log_stream_name=}")
    print('event', json.dumps(event))
    sys.path.append("/opt")
    from mlb_statsapi.model import StatsAPI
    game = event["game"]
    player_sns_input = []
    for team in game["teams"].values():
        player_sns_input.extend(get_player_sns_input_for_team(StatsAPI.Team.roster, team, game["officialDate"]))
    return {
        "players": player_sns_input
    }
