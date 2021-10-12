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
def person(**kwargs):
    method = kwargs["method"]
    season = kwargs["season"]
    force = kwargs["force"]
    personIds = sorted(set(kwargs["personIds"]))
    persons = set()
    for personId in personIds:
        Person: StatsAPIObject = StatsAPI.API_MAP[apiName].methods[method](
            path_params={"personId": personId},
            query_params={"season": season}.copy()
        )
        if force or (not S3().exists(Person.bucket, Person.prefix())):
            Person.get().gzip()
            Person.upload_file()
            persons.add(Person)
    return {
        "method": method,
        "season": season,
        "personIds": personIds,
        "force": force,
        "size": [
            {
                "file": Person.gz_path,
                "size": os.path.getsize(Person.gz_path)
            } for Person in persons
        ]
    }



