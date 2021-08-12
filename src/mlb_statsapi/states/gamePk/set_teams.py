"""
created by nikos at 8/11/21
"""

def lambda_handler(event: dict, context):
    raise NotImplementedError()


def lambda_handler2(event: dict, context) -> bool:
    print(f"{context.function_name=}, {context.function_version=}")
    print('event', json.dumps(event))
    sys.path.append("/opt")
    from mlb_statsapi.model import StatsAPI
    date = strpdate(event["date"])
    game = event["game"]
    StatsAPI.Team.teams(
        query_params={
            "sportId": 1,
            "date": date
        }
    ).get().obj["dates"]
