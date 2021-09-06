import json
import os
import unittest

from unittest.mock import patch

import boto3

from mlb_statsapi.utils.aws import AWS_REGION, StepFunctions
from tests.mlb_statsapi.functions import LambdaTestCase

ACCOUNT = boto3.client('sts').get_caller_identity()["Account"]
QU = f"https://sqs.{AWS_REGION}.amazonaws.com/{ACCOUNT}/mlb-statsapi-workflow-{AWS_REGION}"
SFN = f"arn:aws:states:{AWS_REGION}:{ACCOUNT}:stateMachine:mlb_statsapi_etl_%s"
os.environ["MLB_STATSAPI__WORKFLOW_QUEUE_URL"] = QU
os.environ["MLB_STATSAPI__GAMEDAY_SFN_ARN"] = SFN % "gameday"
os.environ["MLB_STATSAPI__SEASON_SFN_ARN"] = SFN % "season"
os.environ["MLB_STATSAPI__PREGAME_SFN_ARN"] = SFN % "pregame"
os.environ["MLB_STATSAPI__SCHEDULE_SFN_ARN"] = SFN % "schedule"
os.environ["MLB_STATSAPI__GAME_SFN_ARN"] = SFN % "game"
print("using AWS_PROFILE", os.environ["AWS_PROFILE"])


# eue-url https://sqs.us-west-2.amazonaws.com/623650261134/mlb-statsapi-workflow-us-west-2
def test_run_workflow(func: callable) -> callable:
    def run(self, *args, **kwargs):
        workflow = func.__name__.lstrip("test_run_")
        c = self.event["context"]
        self.event = {
            **self.event[workflow],
            "context": c
        }
        return func(self, *args, **kwargs)
    return run


class TestRunWorkflow(LambdaTestCase):

    _queue_name = "mlb-statsapi-workflow-us-west-2"

    @test_run_workflow
    def test_run_mlb_statsapi_etl_schedule(self):
        arns = []
        with patch('mlb_statsapi.functions.run_workflow.delete_message', return_value=None):
            for execution in super(TestRunWorkflow, self).test_lambda_handler():
                arn = execution["executionArn"]
                print("test_run_mlb_statsapi_etl_schedule started", arn)
                arns.append(arn)
        sfn = boto3.client("stepfunctions", region_name=AWS_REGION)
        for arn in arns:
            sfn.stop_execution(executionArn=arn)
            print("test_run_mlb_statsapi_etl_schedule stopped", arn)

    @test_run_workflow
    def test_run_mlb_statsapi_etl_gameday(self):
        arns = []
        with patch('mlb_statsapi.functions.run_workflow.delete_message', return_value=None):
            for execution in super(TestRunWorkflow, self).test_lambda_handler():
                arn = execution["executionArn"]
                print("test_run_mlb_statsapi_etl_gameday started", arn)
                arns.append(arn)
        # sfn = boto3.client("stepfunctions", region_name=AWS_REGION)
        # for arn in arns:
        #     sfn.stop_execution(executionArn=arn)
        #     print("test_run_mlb_statsapi_etl_gameday stopped", arn)

    def test_lambda_handler(self):
        pass


if __name__ == '__main__':
    unittest.main()
