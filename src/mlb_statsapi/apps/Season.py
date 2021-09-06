"""
created by nikos at 8/4/21
"""
import json
import os.path
import traceback

from time import sleep

import utils.stats_api_object
from mlb_statsapi.utils.stats_api_object import StatsAPIObject
from utils.aws import S3

apiName = os.path.basename(__file__).replace('.py', '')


# noinspection PyPep8Naming
def season(**kwargs):
    """
    get the schedule and save it if it changed,
    """
    from mlb_statsapi.model import StatsAPI
    force = kwargs["force"]
    sportId = kwargs["sportId"]
    method = kwargs["method"]
    seasonIds = kwargs["seasonIds"]
    seasons, sizes = [], []
    for seasonId in seasonIds:
        Season: StatsAPIObject = StatsAPI.Season.season(
            path_params={"seasonId": seasonId},
            query_params={"sportId": sportId}).get()
        if force or (not S3().exists(Season.bucket, Season.prefix())):
            Season.gzip()
            Season.upload_file()
            sizes.append(({
                "file": Season.gz_path,
                "size": os.path.getsize(Season.gz_path)
            }))
        seasons.extend(Season.obj["seasons"])

    return {
        "app": apiName,
        "method": method,
        "seasonIds": seasonIds,
        "sportId": sportId,
        "seasons": seasons,
        "size": sizes
    }
