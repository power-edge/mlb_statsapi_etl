"""
created by nikos at 8/5/21
"""
import boto3
import json
import os
import sys


Env = os.environ["Env"]
REGION = os.environ["REGION"]
EVENT_QUEUE_URL = os.environ["MLB_STATSAPI__EVENT_QUEUE_URL"]


def upload_file(method, path_params: dict = None, query_params: dict = None):
    from mlb_statsapi.utils.stats_api_object import StatsAPIObject
    obj: StatsAPIObject = method(path_params=path_params, query_params=query_params).get()
    obj.gzip()
    obj.upload_file()
    return {
        "bucket": obj.bucket,
        "prefix": obj.prefix(),
        "size": os.path.getsize(obj.gz_path),
        "endpoint": obj.endpoint.get_name(),
        "path_params": obj.path_params,
        "query_params": obj.query_params
    }


def process_record(StatsAPI, sqs, record):
    print(f"process_record: {record=}")
    receiptHandle = record["receiptHandle"]
    body = json.loads(record['body'])
    Message = json.loads(body['Message'])
    method = StatsAPI.API_MAP[
        Message["api"]
    ].methods[
        Message["method"]
    ]
    upload_result = upload_file(method, path_params=Message["path_params"], query_params=Message["query_params"])
    sqs.delete_message(QueueUrl=EVENT_QUEUE_URL, ReceiptHandle=receiptHandle)
    return {
        "messageId": record["messageId"],
        "api": Message["api"],
        "method": Message["method"],
        **upload_result
    }


def process_event(event, context):
    from mlb_statsapi.model import StatsAPI
    from mlb_statsapi.utils.aws import SQS
    sqs = SQS(boto3.client('sqs', region_name=REGION))
    response = []
    for record in event["Records"]:
        response.append(process_record(StatsAPI, sqs, record))
    return response


def lambda_handler(event: dict, context) -> bool:
    print(f"{context.function_name=}:{context.function_version=}, {context.log_group_name=}:{context.log_stream_name=}")
    print('event', json.dumps(event))
    sys.path.append("/opt")
    return process_event(event, context)