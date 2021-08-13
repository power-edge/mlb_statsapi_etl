"""
created by nikos at 7/20/21
"""
import json
import os


from .log import LogMixin


class AWSClient(LogMixin):

    def __init__(self, client):
        self._client = client


def check_response(func):
    """method annotation to check the HTTPStatusCode for boto3 calls"""
    def checker(self: AWSClient, *args, **kwargs):
        print(f"{func.__name__} {args=} {kwargs=}")
        res = func(self, *args, **kwargs)
        assert res['ResponseMetadata']['HTTPStatusCode'] == 200, f"{func.__name__} failed: {str(res)}"
        return res
    return checker

# # noinspection PyPep8Naming
# class DynamoDB(AWSClient):
#
#     @check_response
#     def put_item(
#         self,
#         TableName: str,
#         Item: dict,
#         # ReturnValues='ALL_NEW',  # NONE, ALL_OLD, UPDATED_OLD, UPDATED_NEW
#         # ReturnConsumedCapacity='INDEXES',  # | 'TOTAL' | 'NONE'
#         # ReturnItemCollectionMetrics='SIZE',  # | 'NONE'
#         # ConditionExpression=None,
#         # ExpressionAttributeNames: dict = None,
#         # ExpressionAttributeValues: dict = None
#     ):
#         return self._client.put_item(
#             TableName=TableName,
#             Item=Item,
#             # ReturnValues=ReturnValues,
#             # ReturnConsumedCapacity=ReturnConsumedCapacity,
#             # ReturnItemCollectionMetrics=ReturnItemCollectionMetrics,
#             # ConditionExpression=ConditionExpression,
#             # ExpressionAttributeNames=ExpressionAttributeNames,
#             # ExpressionAttributeValues=ExpressionAttributeValues,
#         )


# noinspection PyPep8Naming
class S3(AWSClient):

    @check_response
    def get_object(self, Bucket, Key):
        return self._client.get_object(Bucket=Bucket, Key=Key)

    @check_response
    def head_object(self, Bucket, Key):
        return self._client.head_object(Bucket=Bucket, Key=Key)

    @check_response
    def list_objects_v2(self, Bucket, Prefix):
        return self._client.list_objects_v2(Bucket=Bucket, Prefix=Prefix)

    @check_response
    def put_object(self, Body, Bucket, Key):
        return self._client.put_object(Body=Body, Bucket=Bucket, Key=Key)

    # NO check_response: does not provide the HTTPStatusCode!!!
    def upload_file(self, Bucket, Key, Filename):
        print(f"upload_file {Bucket=} {Key=} {Filename=}")
        return self._client.upload_file(Bucket=Bucket, Key=Key, Filename=Filename)

    # NO check_response: does not provide the HTTPStatusCode!!!
    def download_file(self, Bucket, Key, Filename):
        print(f"download_file {Bucket=} {Key=} {Filename=}")
        res = self._client.download_file(Bucket=Bucket, Key=Key, Filename=Filename)
        assert os.path.isfile(Filename), f"download_file failed: {str(res)}"
        return res


# noinspection PyPep8Naming
class SNS(AWSClient):

    @check_response
    def publish(self, TopicArn, Subject, Message, MessageAttributes):
        return self._client.publish(
            TopicArn=TopicArn, Subject=Subject, Message=Message, MessageAttributes=MessageAttributes
        )


# noinspection PyPep8Naming
class StepFunctions(AWSClient):

    @check_response
    def describe_execution(self, executionArn):
        return self._client.describe_execution(executionArn=executionArn)

    @check_response
    def get_execution_history(self, executionArn):
        return self._client.get_execution_history(executionArn=executionArn)

    @check_response
    def start_execution(self, stateMachineArn, name, _input):
        return self._client.start_execution(stateMachineArn=stateMachineArn, name=name, input=_input)

    @check_response
    def send_task_success(self, taskToken, output):
        return self._client.send_task_success(taskToken=taskToken, output=output)

    @check_response
    def send_task_failure(self, taskToken, error, cause):
        return self._client.send_task_failure(taskToken=taskToken, error=error, cause=cause)

    @check_response
    def stop_execution(self, executionArn):
        return self._client.stop_execution(executionArn=executionArn)


# noinspection PyPep8Naming
class STS(AWSClient):

    @check_response
    def assume_role(self, RoleArn, RoleSessionName, ExternalId=None):
        return self._client.assume_role(RoleArn=RoleArn, RoleSessionName=RoleSessionName, ExternalId=ExternalId)


if __name__ == "__main__":
    import boto3
    from mlb_statsapi.model import StatsAPI
    # sch = StatsAPI.Schedule.schedule(query_params={"sportId": 1}).get()
#     # ddb = DynamoDB(boto3.client("dynamodb", region_name="us-west-2"))
#     dynamodb = boto3.resource(
#         'dynamodb',
#         region_name="us-west-2",
#         endpoint_url="https://dynamodb.us-west-2.amazonaws.com"
#     )
#     table_name = "mlb-statsapi-us-west-2-gameday"
#     # table = dynamodb.Table(table_name)
#     # res = table.put_item(Item={
#     #     "hash_key": sch.keyspace,
#     #     **sch.obj
#     # })
