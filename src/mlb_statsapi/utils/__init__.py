"""
created by nikos at 5/2/21
"""
import datetime
import os
import pytz

base_path = os.path.realpath(__file__).split('/src/')[0]

TZ_America_New_York = pytz.timezone("America/New_York")

def check_response(func):
    """method annotation to check the HTTPStatusCode for boto3 calls"""
    def checker(*args, **kwargs):
        res = func(*args, **kwargs)
        assert res['ResponseMetadata']['HTTPStatusCode'] == 200, f"{func.__name__} failed: {str(res)}"
        return res
    return checker


def get_current_mlb_date() -> datetime.date:
    return datetime.datetime.now(tz=TZ_America_New_York).date()