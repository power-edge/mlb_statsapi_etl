"""
created by nikos at 5/2/21
"""
import datetime
import os
from functools import reduce


CONFIGS_PATH = os.environ.get(
    'MLB_STATSAPI__CONFIGS_PATH',
    "%s/configs" % reduce(lambda d, _: os.path.dirname(d), range(4), os.path.realpath(__file__))
)


def TZ_America_New_York():
    import pytz
    return pytz.timezone("America/New_York")


def check_response(func):
    """method annotation to check the HTTPStatusCode for boto3 calls"""
    def checker(*args, **kwargs):
        res = func(*args, **kwargs)
        assert res['ResponseMetadata']['HTTPStatusCode'] == 200, f"{func.__name__} failed: {str(res)}"
        return res
    return checker


def get_current_mlb_datetime() -> datetime.datetime:
    return datetime.datetime.now(tz=TZ_America_New_York())


def get_current_mlb_date() -> datetime.date:
    return get_current_mlb_datetime().date()


date_format = "%Y-%m-%d"
YmdTHMSz_format = "%Y-%m-%dT%H:%M:%S%z"
game_date_format = YmdTHMSz_format
game_timestamp_format = "%Y%m%d_%H%M%S"


def strpdate(string: str) -> datetime.date:
    return datetime.datetime.strptime(string, date_format).date()


def strpdatetime(string: str, _format=game_date_format) -> datetime.datetime:
    return datetime.datetime.strptime(string, _format)


def strfdatetime(_datetime: datetime.datetime, _format=game_date_format) -> str:
    return _datetime.strftime(_format)