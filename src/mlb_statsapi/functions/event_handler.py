"""
created by nikos at 8/5/21
"""
import json
import os
import sys
# noinspection PyPackageRequirements

from mlb_statsapi.model import StatsAPI
from mlb_statsapi.utils.aws import SQS
from mlb_statsapi.utils.stats_api_object import upload_file


# noinspection PyPep8Naming
def process_record(record):
    # todo: use sqs client to process records into the deadletter queue?
    print(f"process_record: {record=}")
    body = json.loads(record['body'])
    Message = json.loads(body['Message'])
    api = StatsAPI.API_MAP[
        Message["api"]
    ]
    method = api.methods[
        Message["method"]
    ]
    upload_result = upload_file(method, Message["path_params"], Message["query_params"], Message.get("force", False))
    return {
        "messageId": record["messageId"],
        "api": Message["api"],
        "method": Message["method"],
        **upload_result
    }


def process_event(event, context):
    # todo: use context log details in processing the message
    response = []
    for record in event["Records"]:
        response.append(process_record(record))
        SQS().delete_message(QueueUrl=os.environ["MLB_STATSAPI__EVENT_QUEUE_URL"], ReceiptHandle=record["receiptHandle"])
    return response


def lambda_handler(event: dict, context):
    print(f"{context.function_name=}:{context.function_version=}, {context.log_group_name=}:{context.log_stream_name=}")
    print('event', json.dumps(event))
    sys.path.append("/opt")
    return process_event(event, context)
