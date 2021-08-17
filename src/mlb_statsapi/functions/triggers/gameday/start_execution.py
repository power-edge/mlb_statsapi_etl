"""
created by nikos at 8/5/21
"""
import boto3
import json
import os
import sys


STATE_MACHINE_ARN = os.environ["STATE_MACHINE_ARN"]
DATE: str = None


def get_name(event: dict) -> str:
    uid = event["id"]
    date = DATE.replace("-", "")
    return f"gameday-{date}-{uid}"


def start_execution(event: dict):
    from mlb_statsapi.utils.aws import StepFunctions
    return StepFunctions(boto3.client('stepfunctions', region_name=event["region"])).start_execution(
        stateMachineArn=STATE_MACHINE_ARN,
        name=get_name(event),
        input=json.dumps({
            "date": DATE
        })
    )


def lambda_handler(event: dict, context) -> bool:
    print(f"{context.function_name=}:{context.function_version=}, {context.log_group_name=}:{context.log_stream_name=}")
    print('event', json.dumps(event))
    sys.path.append("/opt")
    global DATE
    DATE = event["time"][:10]
    res = start_execution(event)
    return {
        "executionArn": res["executionArn"],
        "startDate": res["startDate"]
    }
