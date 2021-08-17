"""
created by nikos at 8/5/21
"""
import boto3
import json
import os
import sys

from mlb_statsapi.functions import strpdate, strfdatetime, YmdTHMSz_format


SEASON_SFN_ARN = os.environ["MLB_STATSAPI__SEASON_SFN_ARN"]


class WorkflowInput:

    @classmethod
    def mlb_statsapi_etl_season(cls, event, context):
        workflowName = event["workflow"]["name"]
        uid = event["id"]
        date = event["time"].split("T")[0]
        date_nodash = date.replace("-", "")
        return {
            "name": f"{workflowName}-{date_nodash}-{uid}",
            "input": json.dumps({
                "date": date,
                "message": {
                    "api": "Season",
                    "method": "season",
                    "path_params": {
                        "seasonId": str(strpdate(date).year)
                    },
                    "query_params": {
                        "sportId": 1
                    }
                },
                "context": {
                    "function_name": context.function_name,
                    "function_version": context.function_version,
                    "log_group_name": context.log_group_name,
                    "log_stream_name": context.log_stream_name
                },
                "event": event,
            })
        }



def start_execution(event: dict, context):
    from mlb_statsapi.utils.aws import StepFunctions
    workflowArn = event["workflow"]["arn"]
    workflowInput = {
        SEASON_SFN_ARN: WorkflowInput.mlb_statsapi_etl_season
    }[workflowArn]
    return StepFunctions(boto3.client('stepfunctions', region_name=event["region"])).start_execution(
        stateMachineArn=workflowArn,
        **workflowInput(event, context)
    )


def lambda_handler(event: dict, context) -> bool:
    print(f"{context.function_name=}:{context.function_version=}, {context.log_group_name=}:{context.log_stream_name=}")
    print('event', json.dumps(event))
    sys.path.append("/opt")
    res = start_execution(event, context)
    print(f"{res=}")
    return {
        "executionArn": res["executionArn"],
        "startDate": strfdatetime(res["startDate"], YmdTHMSz_format),
    }
