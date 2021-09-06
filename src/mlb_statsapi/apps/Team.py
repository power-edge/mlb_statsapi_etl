"""
created by nikos at 8/4/21
"""
import json
import os.path
import traceback

from time import sleep

import utils.stats_api_object
from mlb_statsapi.utils.stats_api_object import StatsAPIObject
from model import StatsAPI
from utils.aws import S3

apiName = os.path.basename(__file__).replace('.py', '')


# noinspection PyPep8Naming
def roster(**kwargs):
    method = kwargs["method"]
    rosterType = kwargs["rosterType"]
    teamIds = sorted(set(kwargs["teamIds"]))
    force = kwargs["force"]
    path_params = {"rosterType": rosterType}
    query_params = {}
    if "season" in kwargs:
        query_params["season"] = kwargs["season"]
    else:
        query_params["date"] = kwargs["date"]
    if kwargs.get("gameType") is not None:
        query_params["gameTypes"] = kwargs["gameType"]
    teams, persons = set(), set()
    for teamId in teamIds:
        Team: StatsAPIObject = StatsAPI.Team.roster(
            path_params={"teamId": teamId, **path_params},
            query_params=query_params.copy()
        )
        if force or (not S3().exists(Team.bucket, Team.prefix())):
            Team.get().gzip()
            Team.upload_file()
            teams.add(Team)
        if Team.obj is None:
            Team.download_file()
            Team.load()
        [persons.add(person["person"]["id"]) for person in Team.obj["roster"]]

    return {
        "method": method,
        "path_params": path_params,
        "query_params": query_params,
        "force": force,
        "personIds": sorted(persons),
        "size": [
            {
                "file": team.gz_path,
                "size": os.path.getsize(team.gz_path)
            } for team in teams
        ]
    }



