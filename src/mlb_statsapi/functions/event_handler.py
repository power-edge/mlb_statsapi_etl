"""
created by nikos at 8/5/21
"""
import boto3
import json
import os
import sys
import traceback
from botocore.exceptions import ClientError

Env = os.environ["Env"]
REGION = os.environ["REGION"]
EVENT_QUEUE_URL = os.environ["MLB_STATSAPI__EVENT_QUEUE_URL"]


def exists(client, bucket, key: str) -> bool:
    try:
        from mlb_statsapi.utils.aws import S3
        S3(client).head_object(Bucket=bucket, Key=key)
        return True
    except ClientError as e:
        if e.response["ResponseMetadata"]["HTTPStatusCode"] != 404:
            raise e
    return False


def upload_file(method, path_params: dict = None, query_params: dict = None, force: bool = False):
    from mlb_statsapi.utils.stats_api_object import StatsAPIObject
    client = boto3.client('s3', region_name=REGION)
    obj: StatsAPIObject = method(path_params=path_params, query_params=query_params)
    res = {
        "bucket": obj.bucket,
        "prefix": obj.prefix(),
        "endpoint": obj.endpoint.get_name(),
        "path_params": obj.path_params,
        "query_params": obj.query_params,
        "force": force
    }
    if force or (not exists(client, obj.bucket, obj.prefix())):
        obj.get().gzip()
        obj.upload_file(client=client)
        res.update({
            "size": os.path.getsize(obj.gz_path),
        })
    return res


def process_record(StatsAPI, sqs, record):
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
    from mlb_statsapi.model import StatsAPI
    from mlb_statsapi.utils.aws import SQS
    sqs = SQS(boto3.client('sqs', region_name=REGION))
    response = []
    for record in event["Records"]:
        response.append(process_record(StatsAPI, sqs, record))
        sqs.delete_message(QueueUrl=EVENT_QUEUE_URL, ReceiptHandle=record["receiptHandle"])
    return response


def lambda_handler(event: dict, context) -> bool:
    print(f"{context.function_name=}:{context.function_version=}, {context.log_group_name=}:{context.log_stream_name=}")
    print('event', json.dumps(event))
    sys.path.append("/opt")
    return process_event(event, context)