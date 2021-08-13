"""
created by nikos at 8/5/21
"""
import datetime


date_format = "%Y-%m-%d"
game_date_format = "%Y-%m-%dT%H:%M:%S%z"
game_timestamp_format = "%Y%m%d_%H%M%S"


def strpdate(string: str) -> datetime.date:
    return datetime.datetime.strptime(string, date_format).date()


def strp_game_date(string: str, _format=game_date_format) -> datetime.datetime:
    return datetime.datetime.strptime(string, _format)


def strf_game_date(_datetime: datetime.datetime, _format=game_date_format) -> str:
    return _datetime.strftime(_format)



