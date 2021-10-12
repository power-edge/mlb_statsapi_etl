"""
created by nikos at 8/5/21
"""
import uuid

import boto3
import json
import os
import sys
from datetime import datetime

from mlb_statsapi.utils.aws import AWS_REGION, SQS
from mlb_statsapi.utils import YmdTHMSz_format, strpdate, strfdatetime

WORKFLOW_QUEUE_URL = os.environ["MLB_STATSAPI__WORKFLOW_QUEUE_URL"]

GAMEDAY_SFN_ARN = os.environ["MLB_STATSAPI__GAMEDAY_SFN_ARN"]
SEASON_SFN_ARN = os.environ["MLB_STATSAPI__SEASON_SFN_ARN"]
PREGAME_SFN_ARN = os.environ["MLB_STATSAPI__PREGAME_SFN_ARN"]
SCHEDULE_SFN_ARN = os.environ["MLB_STATSAPI__SCHEDULE_SFN_ARN"]
GAME_SFN_ARN = os.environ["MLB_STATSAPI__GAME_SFN_ARN"]


class WorkflowInput:

    eid = str(uuid.uuid4()).split("-")[-1]

    # noinspection PyPep8Naming
    @classmethod
    def mlb_statsapi_etl_game(cls, event, context):
        workflowName = event["workflow"]["name"]
        uid = event["id"].split("-")[-1]
        game = event["message"]
        gamePk = game["gamePk"]
        startTimestamp = game["startTimestamp"]
        return {
            "name": f"{workflowName}-{gamePk}-{startTimestamp}-{uid}-{cls.eid}",
            "input": json.dumps({
                "game": game,
                "context": {
                    "log_group_name": context.log_group_name,
                    "log_stream_name": context.log_stream_name
                }
            })
        }

    # noinspection PyPep8Naming
    @classmethod
    def mlb_statsapi_etl_schedule(cls, event, context):
        workflowName = event["workflow"]["name"]
        uid = event["id"].split("-")[-1]
        date = event["message"]["query_params"]["date"]
        date_nodash = date.replace("-", "")
        return {
            "name": f"{workflowName}-{date_nodash}-{uid}-{cls.eid}",
            "input": json.dumps({
                "date": date,
                "context": {
                    "log_group_name": context.log_group_name,
                    "log_stream_name": context.log_stream_name
                }
            })
        }

    # noinspection PyPep8Naming
    @classmethod
    def mlb_statsapi_etl_pregame(cls, event, context):
        workflowName = event["workflow"]["name"]
        uid = event["id"].split("-")[-1]
        game = event["message"]
        game_pk = game["gamePk"]
        startTimestamp = game["startTimestamp"]
        return {
            "name": f"{workflowName}-{game_pk}-{startTimestamp}-{uid}-{cls.eid}",
            "input": json.dumps({
                "game": {
                    **game,
                    "workflow": {
                        "name": GAME_SFN_ARN.split(":")[-1],
                        "arn": GAME_SFN_ARN
                    }
                },
                "context": {
                    "log_group_name": context.log_group_name,
                    "log_stream_name": context.log_stream_name
                }
            })
        }

    # noinspection PyPep8Naming
    @classmethod
    def mlb_statsapi_etl_gameday(cls, event, context):
        workflowName = event["workflow"]["name"]
        uid = event["id"].split("-")[-1]
        date = event["time"].split("T")[0]
        date_nodash = date.replace("-", "")
        return {
            "name": f"{workflowName}-{date_nodash}-{uid}-{cls.eid}",
            "input": json.dumps({
                "date": date,
                "schedule": {
                    "message": {
                        "api": "Schedule",
                        "method": "schedule",
                        "path_params": {},
                        "query_params": {
                            "date": date,
                            "sportId": 1
                        },
                        "workflow": {
                            "name": SCHEDULE_SFN_ARN.split(":")[-1],
                            "arn": SCHEDULE_SFN_ARN
                        }
                    }
                },
                "context": {
                    "log_group_name": context.log_group_name,
                    "log_stream_name": context.log_stream_name
                }
            })
        }

    # noinspection PyPep8Naming
    @classmethod
    def mlb_statsapi_etl_season(cls, event, context):
        workflowName = event["workflow"]["name"]
        uid = event["id"].split("-")[-1]
        date = event["time"].split("T")[0]
        date_nodash = date.replace("-", "")
        return {
            "name": f"{workflowName}-{date_nodash}-{uid}-{cls.eid}",
            "input": json.dumps({
                "date": date,
                "season": {
                    "message": {
                        "api": "Season",
                        "method": "season",
                        "path_params": {
                            "seasonId": str(strpdate(date).year)
                        },
                        "query_params": {
                            "sportId": 1
                        }
                    }
                },
                "context": {
                    "log_group_name": context.log_group_name,
                    "log_stream_name": context.log_stream_name
                }
            })
        }


# noinspection PyPep8Naming
def start_execution(event: dict, context):
    from mlb_statsapi.utils.aws import StepFunctions
    workflowArn = event["workflow"]["arn"]
    workflowInput = {
        SEASON_SFN_ARN: WorkflowInput.mlb_statsapi_etl_season,
        GAMEDAY_SFN_ARN: WorkflowInput.mlb_statsapi_etl_gameday,
        SCHEDULE_SFN_ARN: WorkflowInput.mlb_statsapi_etl_schedule,
        PREGAME_SFN_ARN: WorkflowInput.mlb_statsapi_etl_pregame,
        GAME_SFN_ARN: WorkflowInput.mlb_statsapi_etl_game,
    }[workflowArn]
    return StepFunctions(region_name=event["region"]).start_execution(
        stateMachineArn=workflowArn,
        **workflowInput(event, context)
    )


# noinspection PyPep8Naming
def parse_record(record: dict) -> dict:
    timestamp = datetime.fromtimestamp(int(record["attributes"]["SentTimestamp"]) / 1e3)
    body = json.loads(record["body"])
    Message = json.loads(body["Message"])
    workflow = Message.pop("workflow")
    return {
        "type": body["Type"],
        "id": record["messageId"],
        "time": timestamp.strftime(YmdTHMSz_format),
        "region": AWS_REGION,
        "message": Message,
        "resources": [
            body["TopicArn"]
        ],
        "workflow": workflow
    }


# noinspection PyPep8Naming
def delete_message(receiptHandle: str):
    SQS().delete_message(QueueUrl=WORKFLOW_QUEUE_URL, ReceiptHandle=receiptHandle)


def lambda_handler(event: dict, context):
    print(f"{context.function_name=}:{context.function_version=}, {context.log_group_name=}:{context.log_stream_name=}")
    print('event', json.dumps(event))
    sys.path.append("/opt")
    if "Records" in event:
        res = []
        for record in event["Records"]:
            record_as_event = parse_record(record)
            se = start_execution(record_as_event, context)
            res.append({
                "executionArn": se["executionArn"],
                "startDate": strfdatetime(se["startDate"], YmdTHMSz_format),
            })
            delete_message(record["receiptHandle"])
    else:
        se = start_execution(event, context)
        res = [{
            "executionArn": se["executionArn"],
            "startDate": strfdatetime(se["startDate"], YmdTHMSz_format),
        }]

    return res
